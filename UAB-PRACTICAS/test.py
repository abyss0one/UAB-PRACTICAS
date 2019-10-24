
file = open('./netflix.csv', 'r')
first = True
for line in file:
    if first:
        first = False
        continue

    rating = line.split(',')[5]
    if not rating.isnumeric():
        continue

    if 65 <= int(rating) < 75:
        print(rating, '--->',line)
