# UK-Local-Media-And-News-Issues-
Searchable CSV Database File Of UK Local News Issues From Local News Web Sites, With 'Key Terms.'

Here's a Perl 5.x script that does the following:

1. Scrapes a list of UK regional news sites and associated Facebook pages.
2. Uses LWP::UserAgent, Mojo::DOM, and Text::CSV for scraping and CSV generation.
3. Extracts content matching political topics using regex key terms.
4. Saves data to a searchable 'uklocalmedianews.csv'.

Includes:

A. CLI Search Tool.
B. A simple Mojolicious Web Viewer.


✅ Usage Instructions

1. Run the script for scraping + web app:

perl uklocalmedianews_csv.pl OR $ sudo ./uklocalmedianews_csv.pl on UNIX/LINUX and MacOS platforms

Access at: http://localhost:3010


2. Run in CLI search mode:

perl uklocalmedianews_csv.pl --cli

You can search using any keyword or topic.

---

✅ Dependencies (Install with CPAN/cpanm)

cpan install LWP::UserAgent Mojo::DOM Text::CSV Mojolicious


---

✅ Output

uklocalmedianews.csv: Contains rows like:

Source URL | Facebook Page | Topic | Snippet Matched
