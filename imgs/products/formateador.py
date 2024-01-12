from PIL import Image
import glob

def has_dalle_mark(img: Image) -> bool:
    a, b, c, d, e = (img.getpixel((int(img.size[0] * x), int(img.size[1]*0.99))) for x in [0.99, 0.974, 0.961, 0.945, 0.928])
    return all([a[0] < 200, a[1] < 200, a[2] > 200, b[0] > 200, b[1] < 200, b[2] < 200, c[0] < 200, c[1] > 150, c[2] < 200, d[0] < 200, d[1] > 200, d[2] > 200, e[0] > 200, e[1] > 200, e[2] < 200])

def remove_dalle_mark(img: Image) -> Image:
    for i in range(int(img.size[1]*0.977), img.size[1]):
        for j in range(int(img.size[0]*0.915), img.size[0]):
            img.putpixel((j,i), tuple(int(sum(k)/2) for k in zip(img.getpixel((j, i-1)), img.getpixel((j-1, i)))))
    return img

for fruit_file in glob.glob('./*.png'):
    fruit_img = Image.open(fruit_file)
    if has_dalle_mark(fruit_img):
        print(f'Fixing {fruit_file}')
        remove_dalle_mark(fruit_img).save(fruit_file)
    else:
        print(f'{fruit_file} has no Dall-E mark')