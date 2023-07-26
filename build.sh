#!/bin/bash

# TO DO:

head=$( cat src/head.htm )
foot=$( cat src/foot.htm )



if ! [ -d site ]; then
	mkdir site
fi

rm site/*.html
#cp src/main.css site/

if ! [ -d etc/tags ]; then
	mkdir -p etc/tags
fi
rm etc/tags/*.txt

#cp src/main.css site/



rss="<?xml version='1.0' encoding='UTF-8' ?>
<rss version='2.0'>
<channel>
<title>cat game devlog</title>
<link>https://cat.tib.ooo/</link>
<description>devlog for cat frend game ooo</description>"



# posts

posts_full=""
posts_toc=""
for i in $( ls -r src/posts/*.htm ); do
	name=$( echo "$i" | sed 's/src\/posts\///' | sed 's/\.htm//' )
	echo "-- $name"
	modified_raw="$( git log --pretty=format:'%ci' -- $i | head -1 | sed 's/^20//' )"
	modified="${modified_raw:0:8}"
	mod_string=""
	if [ "$name" != "$modified" ]; then
		mod_string=" <i class='edited'>(edited $modified)</i>"
	fi
	prettyname=$( head -3 $i | tail -1 | sed 's/<h2>//' | sed 's/<\/h2>//' )
	author=$( head -2 $i | tail -1 )
	author_format=$( echo "${author,,}" | sed 's/ /_/' )
	echo "<li><a href=\"$name.html\">$prettyname</a></li>" >> etc/tags/$author_format.txt
	tags_raw=$( head -1 $i )
	tags=""
	for n in ${tags_raw[@]}; do
		tags+="<a href=\"$n.html\">$n</a> "
		echo "<li><a href=\"$name.html\">$prettyname</a></li>" >> etc/tags/$n.txt
	done
	#main="<h1>$prettyname</h1>$( tail -n +3 $i )"
	main="<p><a href='posts.html#$name'>&lt; Back</a></p><center><small>$name$mod_string</small></center><h1>$prettyname</h1><p class='author'>by <a href='$author_format.html'>$author</a></p>$( tail -n +4 $i )"
	# standalone page
	page="$head$main<br><p class='tags'>Tags: $tags</p>$foot"
	posts_toc+="<li><small>$name</small> <a href='#$name'>$prettyname</a></li>"
	posts_full+="<br><a id=\"$name\"></a><div class='post'><small>$name$mod_string<br>by <a href='$author_format.html'>$author</a></small><br>$( tail -n +3 $i | sed 's/<h2>/<h2><a href='$name.html'>/' | sed 's/<\/h2>/<\/a><\/h2>/' )<br><p class='tags'>Tags: $tags</p></div>"
	rss+="
<item>
  <title>$prettyname</title>
  <link>https://cat.tib.ooo/site/$name.html</link>
  <pubDate>$name</pubDate>
  <description>
<![CDATA[$( tail -n +4 $i )]]>
  </description>
</item>"
	echo "$page" > site/$name.html
done

# main posts page
posts_top=$( cat src/posts-top.htm )
echo "$head$posts_top<br><h4>posts:</h4><ul>$posts_toc</ul>$posts_full$foot" > site/posts.html

# rss foot & write
rss+="</channel></rss>"
echo "$rss" > site/rss.xml


# tags
all_tags=""
for i in $( ls etc/tags/*.txt ); do
	name=$( echo "$i" | sed 's/etc\/tags\///' | sed 's/\.txt//' )
	all_tags+="<li><a href='$name.html'>$name</a></li>"
	echo "$head<h1>pages tagged with '<font style='color:var(--color4);'>$name</font>'</h1><ul>$( cat $i )</ul><br><p><a href='tags.html'>see all tags</a></p>$foot" > site/$name.html
done
echo "$head<h1>TAGS</h1><ul>$all_tags</ul>$foot" > site/tags.html
