package main

import (
	"context"
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"hash/fnv"
	"io"
	"log"
	"net"
	"os"
	"strings"
	"time"

	MQTT "github.com/eclipse/paho.mqtt.golang"
	"go.rbn.im/neinp"
	"go.rbn.im/neinp/fid"
	"go.rbn.im/neinp/fs"
	"go.rbn.im/neinp/message"
	"go.rbn.im/neinp/qid"
	"go.rbn.im/neinp/stat"
)

var sensors = map[string]io.ReadSeeker{
	"bmp280_temperature_celsius": strings.NewReader(""),
	"bmp280_pressure_mbar":       strings.NewReader(""),
	"scd30_temperature_celsius":  strings.NewReader(""),
	"scd30_humidity_percent":     strings.NewReader(""),
	"scd30_co2_ppm":              strings.NewReader(""),
}

func updateSensors(broker, topic, user, password *string) {
	opts := MQTT.NewClientOptions()
	opts.AddBroker(*broker)
	opts.SetUsername(*user)
	opts.SetPassword(*password)

	c := make(chan [2]string)

	opts.SetDefaultPublishHandler(func(client MQTT.Client, msg MQTT.Message) {
		c <- [2]string{msg.Topic(), string(msg.Payload())}
	})

	client := MQTT.NewClient(opts)
	if token := client.Connect(); token.Wait() && token.Error() != nil {
		fmt.Println(token.Error())
		os.Exit(1)
	}

	if token := client.Subscribe(*topic, 0, nil); token.Wait() && token.Error() != nil {
		fmt.Println(token.Error())
		os.Exit(1)
	}

	for {
		msg := <-c

		var f map[string]interface{}
		err := json.Unmarshal([]byte(msg[1]), &f)

		fmt.Println("received MQTT message", msg[1])

		if err == nil {
			for k := range sensors {
				s := fmt.Sprintf("%v", f[k])
				sensors[k] = strings.NewReader(s + "\n")
			}
		}
	}
}

func main() {
	flags := flag.NewFlagSet("sensorfs", flag.ExitOnError)
	flags.Usage = func() {
		fmt.Fprintf(flags.Output(), "%v [OPTIONS]\n", os.Args[0])
		flags.PrintDefaults()
	}
	addr := flags.String("addr", "localhost:5644", "9P address")
	uid := flags.String("uid", "nobody", "uid name")
	gid := flags.String("gid", "nogroup", "gid name")
	debug9 := flags.Bool("debug9", false, "enable 9p debug mode")
	broker := flags.String("broker", "localhost:1883", "MQTT broker")
	topic := flags.String("topic", "co2-sensor", "MQTT topic")
	password := flags.String("password", "", "MQTT password (optional)")
	user := flags.String("user", "", "MQTT user (optional)")
	flags.Parse(os.Args[1:])

	go updateSensors(broker, topic, user, password)

	l, err := net.Listen("tcp", *addr)
	if err != nil {
		log.Fatal(err)
	}

	r := New(*uid, *gid)
	sensors["a"] = strings.NewReader("a")

	for {
		conn, err := l.Accept()
		if err != nil {
			log.Fatal(err)
		}

		s := neinp.NewServer(r)
		s.Debug = *debug9
		go s.Serve(conn)
	}
}

func hashPath(s string) uint64 {
	h := fnv.New64a()
	h.Write([]byte(s))
	return h.Sum64()
}

type SensorFS struct {
	neinp.NopP2000
	root fs.Entry
	fids *fid.Map
}

func New(uid, gid string) *SensorFS {
	r := &SensorFS{}
	r.root = newRootDir(uid, gid)
	r.fids = fid.New()
	return r
}

type sensorReadSeeker struct {
	name string
}

func newSensorReadSeeker(sensorName string) sensorReadSeeker {
	s := sensorReadSeeker{
		name: sensorName,
	}

	return s
}

func (s sensorReadSeeker) Read(p []byte) (n int, err error) {
	return sensors[s.name].Read(p)
}

func (s sensorReadSeeker) Seek(offset int64, whence int) (int64, error) {
	return sensors[s.name].Seek(offset, whence)
}

type rootDir struct {
	*fs.Dir
}

func newRootDir(uid, gid string) *fs.Dir {
	q := qid.Qid{Type: qid.TypeDir, Version: 0, Path: hashPath("/")}
	s := stat.Stat{
		Qid:    q,
		Mode:   0555 | stat.Dir,
		Atime:  time.Now(),
		Mtime:  time.Now(),
		Length: 0,
		Name:   "/",
		Uid:    uid,
		Gid:    gid,
		Muid:   uid,
	}

	children := []fs.Entry{}
	for k := range sensors {
		children = append(children, newSensorFile(k, uid, gid))
	}

	return fs.NewDir(s, children)
}

func newSensorFile(name, uid, gid string) *fs.File {
	q := qid.Qid{Type: qid.TypeFile, Version: 0, Path: hashPath(name)}
	s := stat.Stat{
		Qid:    q,
		Mode:   0444 | stat.Excl,
		Atime:  time.Now(),
		Mtime:  time.Now(),
		Length: 0,
		Name:   name,
		Uid:    uid,
		Gid:    gid,
		Muid:   uid,
	}

	return fs.NewFile(s, newSensorReadSeeker(name))
}

func (r *SensorFS) Version(ctx context.Context, m message.TVersion) (message.RVersion, error) {
	if !strings.HasPrefix(m.Version, "9P2000") {
		return message.RVersion{}, errors.New(message.BotchErrorString)
	}

	return message.RVersion{Version: "9P2000", Msize: m.Msize}, nil
}

func (r *SensorFS) Attach(ctx context.Context, m message.TAttach) (message.RAttach, error) {
	r.fids.Set(m.Fid, r.root)
	return message.RAttach{Qid: r.root.Qid()}, nil
}

func (r *SensorFS) Stat(ctx context.Context, m message.TStat) (message.RStat, error) {
	if e, ok := r.fids.Get(m.Fid).(fs.Entry); ok {
		return message.RStat{Stat: e.Stat()}, nil
	}
	return message.RStat{}, errors.New(message.NoStatErrorString)
}

func (r *SensorFS) Walk(ctx context.Context, m message.TWalk) (message.RWalk, error) {
	e, ok := r.fids.Get(m.Fid).(fs.Entry)
	if !ok {
		return message.RWalk{}, errors.New(message.NotFoundErrorString)
	}

	wqid := []qid.Qid{}

	wentry := e
	for _, v := range m.Wname {
		var err error
		wentry, err = wentry.Walk(v)
		if err != nil {
			return message.RWalk{}, err
		}

		q := wentry.Qid()

		wqid = append(wqid, q)
	}

	if len(m.Wname) == len(wqid) {
		r.fids.Set(m.Newfid, wentry)
	}

	return message.RWalk{Wqid: wqid}, nil
}

func (r *SensorFS) Open(ctx context.Context, m message.TOpen) (message.ROpen, error) {
	e, ok := r.fids.Get(m.Fid).(fs.Entry)
	if !ok {
		return message.ROpen{}, errors.New(message.UnknownFidErrorString)
	}

	q := e.Qid()
	if err := e.Open(); err != nil {
		return message.ROpen{}, errors.New(message.BotchErrorString)
	}

	return message.ROpen{Qid: q}, nil
}

func (r *SensorFS) Read(ctx context.Context, m message.TRead) (message.RRead, error) {
	e, ok := r.fids.Get(m.Fid).(fs.Entry)
	if !ok {
		return message.RRead{}, errors.New(message.UnknownFidErrorString)
	}

	_, err := e.Seek(int64(m.Offset), io.SeekStart)
	if err != nil {
		return message.RRead{}, err
	}

	buf := make([]byte, m.Count)
	n, err := e.Read(buf)
	if err != nil && err != io.EOF {
		return message.RRead{}, err
	}

	return message.RRead{Count: uint32(n), Data: buf[:n]}, nil
}

func (r *SensorFS) Clunk(ctx context.Context, m message.TClunk) (message.RClunk, error) {
	r.fids.Delete(m.Fid)
	return message.RClunk{}, nil
}
