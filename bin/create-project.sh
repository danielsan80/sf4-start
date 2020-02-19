composer create-project symfony/website-skeleton:^4.4 .tmp
mv .tmp/* backend/
mv .tmp/.[^.]* backend/
rmdir .tmp