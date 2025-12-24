#ifndef LIBASM_BONUS_H
# define LIBASM_BONUS_H

# include "libasm.h"

/* ===========================================================================
 * LIBASM BONUS - Funciones adicionales en Assembly 
 *
 * Este header define los prototipos de las funciones bonus implementadas
 * en assembly, incluyendo conversión de bases y manipulación de listas.
 * =========================================================================*/

/* Estructura para listas enlazadas simples */
typedef struct s_list
{
	void			*data;		/* Puntero a los datos del nodo */
	struct s_list	*next;		/* Puntero al siguiente nodo */
}	t_list;

/* Función de conversión de base */
int		ft_atoi_base(char *str, char *base);

/* Funciones de manipulación de listas enlazadas */
void	ft_list_push_front(t_list **begin_list, void *data);
int		ft_list_size(t_list *begin_list);
void	ft_list_sort(t_list **begin_list, int (*cmp)());
void	ft_list_remove_if(t_list **begin_list, void *data_ref,
			int (*cmp)(), void (*free_fct)(void *));

#endif
