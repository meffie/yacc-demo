%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
extern int yylex(void);
extern void yyerror(const char *);
extern int enable_debug;
extern void debug(char *msg);

struct string {
    int slen;
    int blen;
    char *buf;
};

struct list {
    struct list *next;
    struct list *prev;
    struct string *text;
};

struct entry {
    struct entry *next;
    struct entry *prev;
    struct string *date;
    struct string *title;
    struct list *pars;
};

struct string* create_string(char *e);
struct string* add_entity(struct string *s, char *e);
struct list* create_list(struct string *s);
struct list* append(struct list *head, struct list *p);
struct entry * create_entry(struct string *date, struct string *title, struct list *pars);
struct entry * add_entry(struct entry *e, struct entry *n);
void make_blog(struct entry *head);

%}

%union {
    char ch;
    char entity[8];
    struct string *string;
    struct list *list;
    struct entry *entry;
}
%token DATE
%token TITLE
%token PAR
%token <ch> CHAR

%type <entity> entity
%type <string> text date title
%type <list> pars par
%type <entry> entry entries blog

%%
blog: entries           { make_blog($1); }
    ;

entries: entries entry  { $$ = add_entry($1, $2); }
    |    entry          { $$ = $1; }
    ;

entry: date title pars  { $$ = create_entry($1, $2, $3); }

date: DATE text '\n'    { $$ = $2; }
title: TITLE text '\n'  { $$ = $2; }

pars: pars par          { $$ = append($1, $2); }
    | par               { $$ = $1; }
    ;

par: PAR text '\n'      { $$ = create_list($2); }
    ;

text: text entity       { $$ = add_entity($1, $2); }
    | entity            { $$ = create_string($1); }
    ;

entity: CHAR            { $$[0] = $1; $$[1] = '\0'; }
    | '\n'              { strcpy($$, "\n"); }
    | '&'               { strcpy($$, "&amp;"); }
    | '"'               { strcpy($$, "&quot;"); }
    | '\''              { strcpy($$, "&#039;"); }
    | '>'               { strcpy($$, "&gt;"); }
    | '<'               { strcpy($$, "&lt;"); }
    ;

%%

struct string*
create_string(char *e)
{
    struct string* s = malloc(sizeof(struct string));
    s->slen = strlen(e);
    s->blen = 256;
    s->buf = malloc(s->blen);
    strcpy(s->buf, e);
    return s;
}

struct string*
add_entity(struct string *s, char *e)
{
    /* todo: realloc */
    if (s->slen + strlen(e) < s->blen) {
        strcpy(s->buf + s->slen, e);
        s->slen += strlen(e);
    }
    return s;
}

struct list*
create_list(struct string *s)
{
    struct list* p = malloc(sizeof(struct list));
    p->next = p->prev = p;
    p->text = s;
    return p;
}

struct list*
append(struct list *head, struct list *p)
{
    struct list *tail = head->prev;

    tail->next = p;
    head->prev = p;
    p->next = head;
    p->prev = tail;
    return head;
}

struct entry *
create_entry(struct string *date, struct string *title, struct list *pars)
{
    struct entry *e = malloc(sizeof(struct entry));
    e->next = e->prev = e;
    e->date = date;
    e->title = title;
    e->pars = pars;
    return e;
}

struct entry *
add_entry(struct entry *head, struct entry *p)
{
    struct entry *tail = head->prev;

    tail->next = p;
    head->prev = p;
    p->next = head;
    p->prev = tail;
    return head;
}

void
make_blog(struct entry *head)
{
    struct entry *e = head;
    struct list *p;

    printf("<!DOCTYPE html>\n");
    printf("<html>\n");
    printf("<head>\n");
    printf("  <title>yblog</title>\n");
    printf("</head>\n");
    printf("<body>\n");
    do {
        printf("<h1>%s</h1>\n", e->title->buf);
        printf("<h2>%s</h2>\n", e->date->buf);
        p = e->pars;
        do {
            printf("<p>%s</p>\n", p->text->buf);
            p = p->next;
        } while (p != e->pars);
        e = e->next;
    } while (e != head);
    printf("</body>\n");
    printf("</html>\n");
}

void yyerror(const char *s)
{
    fprintf(stderr, "%s\n", s);
    exit(1);
}

int main(int argc, char *argv[])
{
    enable_debug = 0;
    yyparse();
    return 0;
}
