export type User = {
	UserId: number,
	Username: string,
	DisplayName: string,
	AccountAge: number,
	Roles: { string },
	Warnings: {
		{
			Timestamp: number,
			Text: string,
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
	Role: string,
}

return nil
