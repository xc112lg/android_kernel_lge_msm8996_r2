/* mpi-inline.h  -  Internal to the Multi Precision Integers
 *	Copyright (C) 1994, 1996, 1998, 1999 Free Software Foundation, Inc.
 *
 * This file is part of GnuPG.
 *
 * GnuPG is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * GnuPG is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA
 *
 * Note: This code is heavily based on the GNU MP Library.
 *	 Actually it's the same code with only minor changes in the
 *	 way the data is stored; this is to support the abstraction
 *	 of an optional secure memory allocation which may be used
 *	 to avoid revealing of sensitive data due to paging etc.
 *	 The GNU MP Library itself is published under the LGPL;
 *	 however I decided to publish this code under the plain GPL.
 *
 * mpihelp_add_1/mpihelp_add/mpihelp_sub_1/mpihelp_sub used to be defined
 * here as "extern inline". Whether that produces a callable out-of-line
 * copy depends on the compiler's inline dialect (GNU89 vs ISO C99) and,
 * under GNU89, on the inliner actually inlining every call site - which
 * isn't guaranteed. They're now ordinary functions in mpihelp-add.c and
 * mpihelp-sub.c instead, so linkage no longer depends on that. This
 * header is kept (now empty) in case anything still includes it.
 */

#ifndef G10_MPI_INLINE_H
#define G10_MPI_INLINE_H

#endif /*G10_MPI_INLINE_H */
