package main

import (
	"bytes"
	"encoding/csv"
	"fmt"
	"log"
	"net/http"
	"os"
	"strconv"
	"strings"
	"time"

	"github.com/yuin/goldmark/v2/parser"
	"github.com/yuin/goldmark/v2/renderer/html"
)

type Post struct {
	ID             int
	UserID         int
	PublishedAt    time.Time
	CachedUserName string
	MainImage      string
	Title          string
	BodyMarkdown   string
	Slug           string
	Description    string
}

func main() {
	server := http.NewServeMux()

	f, err := os.Open("articles.csv")
	if err != nil {
		log.Fatal("Failed to open csv file")
	}
	defer f.Close()

	posts, err := csv.NewReader(f).ReadAll()
	if err != nil {
		log.Fatal("Failed to read posts from csv")
	}
	idx := createIndex(posts)

	server.HandleFunc("GET /", func(resp http.ResponseWriter, req *http.Request) {
		var indx strings.Builder
		for k, v := range idx {
			fmt.Fprintf(&indx, "<a href='/post/%s'>%s</a></br><p>%s</p></br></br>", k, v.Title, v.Description)
		}
		resp.WriteHeader(http.StatusOK)
		resp.Write([]byte(indx.String()))
	})

	server.Handle("GET /image/", http.StripPrefix("/image/", http.FileServer(http.Dir("./images"))))

	server.HandleFunc("GET /post/{slug}", func(resp http.ResponseWriter, req *http.Request) {
		post := idx[req.PathValue("slug")]

		var buf bytes.Buffer

		p := parser.New()
		r := html.New()

		doc := p.Parse([]byte(post.BodyMarkdown))
		if err := r.Render(&buf, []byte(post.BodyMarkdown), doc); err != nil {
			resp.WriteHeader(http.StatusInternalServerError)
			resp.Write([]byte("Error while parsing post body"))
			return
		}

		body := fmt.Sprintf(`<h1>%s</h1>
			<p>Author: %s</p>
			<p>%s</p>
			</br>
			<img src='/image/%s'/>
			</br>
			%s
		`,
			post.Title,
			post.CachedUserName,
			post.PublishedAt,
			post.MainImage,
			buf.String(),
		)

		resp.WriteHeader(http.StatusOK)
		resp.Write([]byte(body))
	})

	http.ListenAndServe(":8000", server)
}

func createIndex(posts [][]string) map[string]Post {
	idx := make(map[string]Post, len(posts))
	for _, r := range posts {
		id, userId, publishedAt, cUsername, slug, mImage, title, desc, body := r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8]

		parts := strings.Split(mImage, "/")

		p := Post{
			ID:             parseInt(id),
			UserID:         parseInt(userId),
			PublishedAt:    parseTime(publishedAt),
			CachedUserName: cUsername,
			MainImage:      parts[len(parts)-1],
			Title:          title,
			BodyMarkdown:   body,
			Slug:           slug,
			Description:    desc,
		}

		idx[slug] = p
	}
	return idx
}

func parseInt(n string) int {
	i, _ := strconv.Atoi(n)
	return i
}

func parseTime(date string) time.Time {
	t, _ := time.Parse("2006-01-02 15:04:05.99999", date)
	return t
}
