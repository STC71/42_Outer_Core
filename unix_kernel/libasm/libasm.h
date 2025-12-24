#ifndef LIBASM_H
# define LIBASM_H

# include <stddef.h>
# include <stdlib.h>
# include <unistd.h>
# include <string.h>
# include <errno.h>

/* ===========================================================================
 * LIBASM - Biblioteca de funciones en Assembly x86-64
 *
 * Este header define los prototipos de las funciones obligatorias
 * implementadas en assembly para el proyecto libasm.
 * =========================================================================*/

/* Funciones obligatorias de manipulación de strings */
size_t	ft_strlen(const char *s);
char	*ft_strcpy(char *dst, const char *src);
int		ft_strcmp(const char *s1, const char *s2);

/* Funciones obligatorias de E/S (syscalls) */
ssize_t	ft_write(int fd, const void *buf, size_t count);
ssize_t	ft_read(int fd, void *buf, size_t count);

/* Funciones obligatorias de memoria */
char	*ft_strdup(const char *s);

#endif
