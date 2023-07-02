const std = @import("std");

const Token = union(enum) {
    literal: []const u8,
    int: []const u8,

    illegal,
    eof,

    ident,
    assign,
    plus,
    comma,
    semicolon,

    lparen,
    rparen,
    lbrace,
    rbrace,

    func,
    let,

    pub fn keyword(token: []const u8) ?Token {
        const keywords = std.ComptimeStringMap(Token, .{
            .{ "fn", .func },
            .{ "let", .let },
        });

        return keywords.get(token);
    }
};

const Lexer = struct {
    input: []const u8,
    position: usize = 0,
    readPosition: usize = 0,
    ch: u8 = 0,

    pub fn readChar(self: *Lexer) void {
        if (self.readPosition >= self.input.len) {
            self.ch = 0;
        } else {
            self.ch = self.input[self.readPosition];
        }

        self.position = self.readPosition;
        self.readPosition += 1;
    }

    pub fn nextToken(self: *Lexer) Token {
        self.skipWhitespace();
        const tok: Token = switch (self.ch) {
            '=' => .assign,
            ';' => .semicolon,
            '(' => .lparen,
            ')' => .rparen,
            ',' => .comma,
            '+' => .plus,
            '{' => .lbrace,
            '}' => .rbrace,
            'a'...'z', 'A'...'Z', '_' => {
                var literal = self.readIdentifier();
                if (Token.keyword(literal)) |token| {
                    return token;
                }
                return .{ .literal = literal };
            },
            '0'...'9' => {
                var int = self.readInteger();
                return .{ .int = int };
            },
            0 => .eof,
            else => .illegal,
        };

        self.readChar();
        return tok;
    }

    fn readIdentifier(self: *Lexer) []const u8 {
        var position = self.position;
        while (isLetter(self.ch)) {
            self.readChar();
        }

        return self.input[position..self.position];
    }

    fn readInteger(self: *Lexer) []const u8 {
        var position = self.position;
        while (std.ascii.isDigit(self.ch)) {
            self.readChar();
        }

        return self.input[position..self.position];
    }

    fn skipWhitespace(self: *Lexer) void {
        while (std.ascii.isWhitespace(self.ch)) {
            self.readChar();
        }
    }
};

pub fn newLexer(input: []const u8) Lexer {
    var l = Lexer{
        .input = input,
    };
    l.readChar();
    return l;
}

pub fn isLetter(ch: u8) bool {
    return std.ascii.isAlphabetic(ch) or ch == '_';
}

pub fn main() !void {}

test "lexer test" {
    const input = "=+(){},;";
    var l = newLexer(input);

    var tokens = [_]Token{
        .assign,
        .plus,
        .lparen,
        .rparen,
        .lbrace,
        .rbrace,
        .comma,
        .semicolon,
        .eof,
    };

    for (tokens) |token| {
        const tok = l.nextToken();

        try std.testing.expectEqual(token, tok);
    }
}

test "lexer test 2" {
    const input =
        \\let five = 5;
        \\let ten = 10;
        \\let add = fn(x, y) {
        \\  x + y;
        \\};
        \\let result = add(five, ten);
    ;
    var l = newLexer(input);

    var tokens = [_]Token{
        .let,
        .{ .literal = "five" },
        .assign,
        .{ .int = "5" },
        .semicolon,
        .let,
        .{ .literal = "ten" },
        .assign,
        .{ .int = "10" },
        .semicolon,
        .let,
        .{ .literal = "add" },
        .assign,
        .func,
        .lparen,
        .{ .literal = "x" },
        .comma,
        .{ .literal = "y" },
        .rparen,
        .lbrace,
        .{ .literal = "x" },
        .plus,
        .{ .literal = "y" },
        .semicolon,
        .rbrace,
        .semicolon,
        .let,
        .{ .literal = "result" },
        .assign,
        .{ .literal = "add" },
        .lparen,
        .{ .literal = "five" },
        .comma,
        .{ .literal = "ten" },
        .rparen,
        .semicolon,
        .eof,
    };

    for (tokens) |token| {
        var tok = l.nextToken();

        try std.testing.expectEqualDeep(token, tok);
    }
}
