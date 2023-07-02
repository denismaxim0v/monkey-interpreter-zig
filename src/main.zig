const std = @import("std");

const Token = union(enum) {
    literal: []const u8,
    illegal,
    eof,

    ident,
    int,

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
        const tok: Token = switch (self.ch) {
            '=' => .assign,
            ';' => .semicolon,
            '(' => .lparen,
            ')' => .rparen,
            ',' => .comma,
            '+' => .plus,
            '{' => .lbrace,
            '}' => .rbrace,
            0 => .eof,
            else => .illegal,
        };

        self.readChar();
        return tok;
    }
};

pub fn newLexer(input: []const u8) Lexer {
    var l = Lexer{
        .input = input,
    };
    l.readChar();
    return l;
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
