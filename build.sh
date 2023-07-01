#!/bin/bash

# TO DO:
# . RSS feed

head=$( cat src/head.htm )
foot=$( cat src/foot.htm )



if ! [ -d site ]; then
	mkdir site
fi

rm site/*.html
cp src/main.css site/

if ! [ -d etc/tags ]; then
	mkdir -p etc/tags
fi
rm etc/tags/*.txt

cp src/main.css site/



# posts

posts_full=""
posts_toc=""
for i in $( ls -r src/posts/*.htm ); do
	name=$( echo "$i" | sed 's/src\/posts\///' | sed 's/\.htm//' )
	echo "-- $name"
	prettyname=$( tail -n +2 $i | head -1 | sed 's/<h2>//' | sed 's/<\/h2>//' )
	tags_raw=$( head -1 $i )
	tags=""
	for n in ${tags_raw[@]}; do
		tags+="<a href=\"$n.html\">$n</a> "
		echo "<li><a href=\"$name.html\">$prettyname</a></li>" >> etc/tags/$n.txt
	done
	#main="<h1>$prettyname</h1>$( tail -n +3 $i )"
	main="<center><small>$name</small></center><h1>$prettyname</h1>$( tail -n +3 $i )"
	# standalone page
	page="$head$main<br><p>Tags: $tags</p>$foot"
	posts_toc+="<li><small>$name</small> <a href='#$name'>$prettyname</a></li>"
	posts_full+="<br><hr /><br><a id=\"$name\"></a><small>$name</small><br>$( tail -n +2 $i | sed 's/<h2>/<h2><a href='$name.html'>/' | sed 's/<\/h2>/<\/a><\/h2>/' )<br><p>Tags: $tags</p>"
	echo "$page" > site/$name.html
done

# main posts page
posts_top=$( cat src/posts-top.htm )
echo "$head$posts_top<h4>posts:</h4><ul>$posts_toc</ul>$posts_full$foot" > site/posts.html


# tags
all_tags=""
for i in $( ls etc/tags/*.txt ); do
	name=$( echo "$i" | sed 's/etc\/tags\///' | sed 's/\.txt//' )
	all_tags+="<li><a href='$name.html'>$name</a></li>"
	echo "$head<h1>pages tagged with: $name</h1><ul>$( cat $i )</ul><br><p><a href='tags.html'>see all tags</a></p>$foot" > site/$name.html
done
echo "$head<h1>TAGS</h1><ul>$all_tags</ul>$foot" > site/tags.html
