#! /usr/bin/env python

import sys, os, re, Gnuplot, sqlite3, itertools

def gpinit(termtype = None):
    gp = Gnuplot.Gnuplot()
    if not termtype:
        pass
    elif termtype == "eps":
        settermcmd = 'set terminal postscript eps color "Times-Roman,26"'
        gp(settermcmd)
    elif termtype == "png":
        settermcmd = "set terminal png"
        gp(settermcmd)
    else:
        sys.stdout.write("wrong terminal type\n")
    return gp

def query2data(db, query, xcol = 0, ycol = 1, *items, **keyw):
    if isinstance(db, str):
        conn = sqlite3.connect(db)
    else:
        conn = db
    vardict = {}
    for var in re.findall(r'\{\w+\}', query):
        var = var.strip('{}')
        if var not in keyw:
            sys.stdout.write('No keyword argument : {0}\n'.format(var))
            sys.exit(1)
        vardict[var] = keyw.pop(var)
    gdlist = []
    if vardict:
        if 'title' in keyw:
            title = keyw.pop('title')
        else:
            title = ' '.join(['{0}={{{0}}}'.format(var) for var in vardict])
        for vallist in itertools.product(*vardict.values()):
            valdict = {}
            for key, value in zip(vardict, vallist):
                valdict[key] = value
            x, y = [], []
            for r in conn.execute(query.format(**valdict)):
                x.append(r[xcol])
                y.append(r[ycol])
            gdlist.append(Gnuplot.Data(x, y,
                                       title = title.format(**valdict),
                                       *items, **keyw))
    else:
        x, y = [], []
        for r in conn.execute(query):
            x.append(r[xcol])
            y.append(r[ycol])
        gdlist.append(Gnuplot.Data(x, y, *items, **keyw))
    if isinstance(db, str):
        conn.close()
    return gdlist
