
def process_bnf(input_txt, out_bnf, start_page, last_page):

    print('\n\n\nprocess', input_txt, out_bnf, start_page, last_page)
    f = open(input_txt, encoding='utf-8', errors='ignore')
    outfile = open(out_bnf, 'w', encoding='utf-8')

    def pr(left, right):
        a = left + (' '.join(right))
        # print(a)
        b = a.strip().split("::=")[1].strip()
        # print('b=', b)
        # because ' '.split(' ') is ['', '']
        rr = list(filter(lambda s: len(s) > 0, b.split(' ')))
        # print("rr=", rr)
        if len(rr) == 0:
            outfile.write(a + "I_DONT_KNOW\n")
        else:
            print(left, right)
            outfile.write(a.strip()+'\n')

    left = ""
    flag = False
    page = start_page
    while page < last_page:
        l = f.readline()
        if l == "":
            break
        if l.strip().endswith(str(page)):
            for i in range(20):
                x = f.readline().strip()
                if x == "IWD 39075:202y(E)":
                    break
                if i > 10:
                    raise Exception("find page error")
            for i in range(20):
                head = f.readline().strip()
                if head == "":
                    continue
                if i > 10:
                    raise Exception("head not found")
                break
            print('page', page, 'head', head)
            page = page + 1
            continue

        # close
        if len(list(filter(l.startswith, ["Syntax Rules", "**", "«", "!!", "``", "NOTE"]))) > 0:
            if flag:
                pr(left, right)
                flag = False
            continue

        # open
        if "::=" in l and l.startswith("<"):
            if flag:
                flag = False
                pr(left, right)
            flag = True
            left = l.strip()
            right = []
            continue
        if flag:
            s = l.strip()
            off = s.find("!!")
            if off != -1:
                s = s[:off]
            if s != "":
                right.append(s)
            continue
    outfile.close()
    f.close()


process_bnf('gql.txt', 'gql.bnf', 97, 408)
process_bnf('gql_literals.txt', 'gql_symbols.bnf', 409, 586)
