export type Argument = {
	Name: string,
	Type: string,
	Options: { string }?,
	Fallback: any?,
	Optional: boolean?,
}
export type Command = {
	Name: string,
	Arguments: { Argument },
	Roles: { string },
}

local COMMANDS = {
	Command = {
		Name = "command",
		Roles = { "Moderator" },
		Arguments = {},
	},
	Command2 = {
		Name = "command2",
		Roles = { "Admin" },
		Arguments = {
			{
				Name = "Players",
				Type = "UserIds",
				Optional = true,
			},
			{
				Name = "Message",
				Type = "String",
				Optional = true,
			},
		},
	},
	Command3 = {
		Name = "command3",
		Roles = { "VIP" },
		Arguments = {
			{
				Name = "Players",
				Type = "UserIds",
			},
			{
				Name = "Message",
				Type = "String",
			},
		},
	},
	Command4 = {
		Name = "command4",
		Roles = { "Guest" },
		Arguments = {
			{
				Name = "Players",
				Type = "UserIds",
			},
			{
				Name = "Message",
				Type = "String",
			},
		},
	},
	Command5 = {
		Name = "command5",
		Roles = { "Guest" },
		Arguments = {
			{
				Name = "Players",
				Type = "UserIds",
			},
			{
				Name = "Message",
				Type = "String",
			},
		},
	},
	Ban = {
		Name = "ban",
		Roles = { "Moderator" },
		Arguments = {
			{
				Name = "Players",
				Type = "UserIds",
			},
			{
				Name = "Reason",
				Type = "String",
				Optional = true,
			},
		},
	},
	Warn = {
		Name = "warn",
		Roles = { "Moderator" },
		Arguments = {
			{
				Name = "Players",
				Type = "UserIds",
			},
			{
				Name = "Message",
				Type = "String",
			},
		},
	},
	Admin = {
		Name = "admin",
		Roles = { "Admin" },
		Arguments = {
			{
				Name = "Players",
				Type = "UserIds",
			},
			{
				Name = "Role",
				Type = "Enum",
				Options = { "Moderator", "Admin" },
			},
		},
	},
	EveryArgument = {
		Name = "everyargument",
		Roles = { "Moderator" },
		Arguments = {
			{
				Name = "UserIds",
				Type = "UserIds",
			},
			{
				Name = "Number",
				Type = "Number",
			},
			{
				Name = "String",
				Type = "String",
			},
			{
				Name = "Color3",
				Type = "Color3",
			},
			{
				Name = "Boolean",
				Type = "Boolean",
			},
			{
				Name = "TextSwap",
				Type = "TextSwap",
				Options = { "Pizza", "Ice Cream", "Cookies" },
			},
			{
				Name = "Tabs",
				Type = "Tabs",
				Options = { { "Tab1" }, { "Tab2" }, { "Tab3" } },
			},
			{
				Name = "Checklist",
				Type = "Checklist",
				Options = { "Sword", "Slingshot", "Dodgeball" },
			},
			{
				Name = "Duration",
				Type = "Duration",
			},
		},
	},
}

return COMMANDS
