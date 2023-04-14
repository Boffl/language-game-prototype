import csv


def filter(s):
    s = s.lower()
    mentioned = ""
    names = ["susanne", "lisa", "emily", "martin", "samantha", "steven"]
    for name in names:
        if name in s:
            mentioned = name
        s = s.replace(name, "kim")
    return [mentioned, s]

def remove_names():
    with open('full_data.csv') as csv_file:
        csv_reader = csv.reader(csv_file, delimiter=',')
        output = []
        for row in csv_reader:
            filtered = filter(row[-1])
            output.append(filtered)
        print(output[1:])

    with open('Data_no_names1.csv', mode='w', newline="") as employee_file:
        data = csv.writer(employee_file, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
        for row in output[1:]:
            if row != ",":
                data.writerow(row)

def main():
    with open("data.txt", "r")as file:
        file = file.readlines()
        with open('aaaa.csv', mode='w', newline="") as file_:
            data = csv.writer(file_, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
            for line in file:
                split = line.split(",")
                label = split[0]
                txt = ",".join(split[1:])[:-1]
                data.writerow([label, txt])


if __name__ == "__main__":
    remove_names()

