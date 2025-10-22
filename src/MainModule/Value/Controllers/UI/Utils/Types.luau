-- Timestamps are in unix format
-- For durations, -1 is treated as infinite

export type User = {
	UserId: number,
	Username: string,
	DisplayName: string,
	AccountAge: number,
	AgeVerified: boolean,
	Roles: { string },
	Warnings: {
		{
			Timestamp: number,
			Reason: string,
		}?
	},
	Bans: {
		{
			Timestamp: number,
			Duration: number,
			Reason: string,
		}
	},
}

export type Role = {
	Name: string,
	Color: Color3,
	Level: number,
	Gamepass: number?,
}

export type CommandArgument = {
	Name: string,
	Type: string,
	Optional: boolean,
	Fallback: any,
	Options: { string? },
}

export type Command = {
	Name: string,
	Aliases: { string },
	Arguments: { CommandArgument },
	Roles: { string },
	Category: string,
}

export type Prompt = {
	Id: string,
	Title: { string },
	Body: string,
	Lifetime: number?,
	Callback: () -> ()?,
}

return nil
