package extpoints

type CommandFunc func([]string)

type CommandProvider interface {
	Commands() map[string]CommandFunc
}
