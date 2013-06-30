#! /usr/bin/env python

import sys, os, re, Gnuplot, sqlite3, itertools

def gpinit(termtype = None):
    gp = Gnuplot.Gnuplot()
    if not termtype:
        pass
    elif termtype == "eps":
        settermcmd = 'set terminal postscript eps enhanced color "Times-Roman,26"'
        gp(settermcmd)
    elif termtype == "png":
        settermcmd = "set terminal png size 800, 600"
        gp(settermcmd)
    else:
        sys.stdout.write("wrong terminal type\n")
        sys.exit(1)
    return gp

def query2data(db, query):
    if isinstance(db, str): conn = sqlite3.connect(db)
    else: conn = db
    rows = conn.execute(query)
    r = rows.fetchone()
    datalist = [[val] for val in r]
    for r in rows:
        for val, arr in zip(r, datalist): arr.append(val)
    return datalist

def query2gds(db, query, *items, **keyw):
    if isinstance(db, str): conn = sqlite3.connect(db)
    else: conn = db
    vardict = {}
    for var in re.findall(r'\{\w+\}', query):
        var = var.strip('{}')
        if var not in keyw:
            sys.stderr.write('No keyword argument : {0}\n'.format(var))
            return None
        vardict[var] = keyw.pop(var)
    if 'title' in keyw: title = keyw.pop('title')
    else: title = ' '.join(['{0}={{{0}}}'.format(var) for var in vardict])

    gdlist = []
    if vardict:
        for vallist in itertools.product(*vardict.values()):
            valdict = dict(zip(vardict, vallist))
            datalist = query2data(conn, query.format(**valdict))
            if len(datalist) == 2:
                gdlist.append(Gnuplot.Data(datalist[0], datalist[1],
                                           title = title.format(**valdict),
                                           *items, **keyw))
            elif len(datalist) == 3:
                gdlist.append(Gnuplot.Data(datalist[0], datalist[1], datalist[2],
                                           title = title.format(**valdict),
                                           *item, **keyw))
            else:
                sys.stderr.write('Number of output column is not valid\n')
                return None
    else:
        datalist = query2data(conn, query)
        if len(datalist) == 2:
            gdlist.append(Gnuplot.Data(datalist[0], datalist[1],
                                       title = title, *items, **keyw))
        elif len(datalist) == 3:
            gdlist.append(Gnuplot.Data(datalist[0], datalist[1], datalist[2],
                                       title = title, *items, **keyw))
        else:
            sys.stderr.write('Number of output column is not valid\n')
            return None
    if isinstance(db, str): conn.close()
    return gdlist

def ceiltop(val):
    tmp = float(val)
    count = 0
    if tmp == 0.0:
        return tmp
    elif tmp >= 1.0:
        while tmp >= 1.0:
            tmp *= 0.1
            count += 1
        tmp *= 10
        count -= 1
    else:
        while tmp < 1.0:
            tmp *= 10
            count -= 1
    if tmp - int(tmp) == 0.0:
        return int(tmp) * (10. ** count)
    else:
        return (int(tmp) + 1) * (10. ** count)

def floortop(val):
    tmp = float(val)
    count = 0
    if tmp == 0.0:
        return tmp
    elif val >= 1.0:
        while tmp >= 1.0:
            tmp *= 0.1
            count += 1
        tmp *= 10
        count -= 1
    else:
        while tmp < 1.0:
            tmp *= 10
            count -= 1
    return int(tmp) * (10. ** count)
