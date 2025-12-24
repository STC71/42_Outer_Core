/******************************************************************************
 * LIBASM - Test Suite para Funciones Bonus 
 * 
 * Este programa realiza pruebas comprehensivas de todas las funciones
 * bonus implementadas en assembly. Incluye pruebas para conversión
 * de bases y manipulación de listas enlazadas.
 *
 * Funciones probadas:
 *   - ft_atoi_base:        Conversión de string a int en base arbitraria
 *   - ft_list_push_front:  Inserción al inicio de lista
 *   - ft_list_size:        Conteo de elementos
 *   - ft_list_sort:        Ordenamiento de lista
 *   - ft_list_remove_if:   Eliminación condicional de elementos
 *****************************************************************************/

#include "../libasm_bonus.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/* Códigos de color ANSI para salida formateada */
#define GREEN "\033[0;32m"
#define RED "\033[0;31m"
#define BLUE "\033[0;34m"
#define YELLOW "\033[0;33m"
#define RESET "\033[0m"

/******************************************************************************
 * test_atoi_base - Prueba la función ft_atoi_base
 * 
 * Verifica la conversión correcta de strings a enteros en diferentes bases:
 * hexadecimal, binaria, decimal, etc. También prueba validación de bases
 * inválidas.
 *****************************************************************************/
void	test_atoi_base(void)
{
	printf(BLUE "\n=== Testing ft_atoi_base ===\n" RESET);
	
	struct {
		char *str;
		char *base;
		int expected;
	} tests[] = {
		{"2a", "0123456789abcdef", 42},
		{"101010", "01", 42},
		{"-2a", "0123456789abcdef", -42},
		{"52", "0123456789", 52},
		{"  ++--+42", "0123456789", 42},
		{"invalid", "", 0},
		{"42", "0", 0},
		{"42", "01234+6789", 0},
		{NULL, NULL, 0}
	};
	
	for (int i = 0; tests[i].str; i++)
	{
		int result = ft_atoi_base(tests[i].str, tests[i].base);
		printf("ft_atoi_base(\"%s\", \"%s\"): %d ", 
			tests[i].str, tests[i].base, result);
		if (result == tests[i].expected)
			printf(GREEN "✓\n" RESET);
		else
			printf(RED "✗ (expected %d)\n" RESET, tests[i].expected);
	}
}

/******************************************************************************
 * print_list - Función auxiliar para visualizar el contenido de una lista
 * 
 * Parámetros:
 *   list - Puntero al primer elemento de la lista
 *****************************************************************************/
void	print_list(t_list *list)
{
	printf("[");
	while (list)
	{
		printf("%s", (char *)list->data);
		if (list->next)
			printf(" -> ");
		list = list->next;
	}
	printf("]\n");
}

/******************************************************************************
 * test_list_push_front - Prueba la función ft_list_push_front
 * 
 * Verifica que los elementos se inserten correctamente al inicio de la
 * lista y que el orden de inserción sea el esperado.
 *****************************************************************************/
void	test_list_push_front(void)
{
	printf(BLUE "\n=== Testing ft_list_push_front ===\n" RESET);
	
	t_list *list = NULL;
	
	ft_list_push_front(&list, "Third");
	ft_list_push_front(&list, "Second");
	ft_list_push_front(&list, "First");
	
	printf("List after pushing: ");
	print_list(list);
	
	if (list && strcmp((char *)list->data, "First") == 0 &&
		list->next && strcmp((char *)list->next->data, "Second") == 0 &&
		list->next->next && strcmp((char *)list->next->next->data, "Third") == 0)
		printf(GREEN "✓\n" RESET);
	else
		printf(RED "✗\n" RESET);
	
	/* Liberar memoria de la lista */
	while (list)
	{
		t_list *tmp = list;
		list = list->next;
		free(tmp);
	}
}

/******************************************************************************
 * test_list_size - Prueba la función ft_list_size
 * 
 * Verifica que el conteo de elementos sea correcto para listas de
 * diferentes tamaños, incluyendo listas vacías.
 *****************************************************************************/
void	test_list_size(void)
{
	printf(BLUE "\n=== Testing ft_list_size ===\n" RESET);
	
	t_list *list = NULL;
	
	printf("Size of empty list: %d ", ft_list_size(list));
	if (ft_list_size(list) == 0)
		printf(GREEN "✓\n" RESET);
	else
		printf(RED "✗\n" RESET);
	
	ft_list_push_front(&list, "1");
	ft_list_push_front(&list, "2");
	ft_list_push_front(&list, "3");
	ft_list_push_front(&list, "4");
	
	printf("Size of 4-element list: %d ", ft_list_size(list));
	if (ft_list_size(list) == 4)
		printf(GREEN "✓\n" RESET);
	else
		printf(RED "✗\n" RESET);
	
	/* Liberar memoria de la lista */
	while (list)
	{
		t_list *tmp = list;
		list = list->next;
		free(tmp);
	}
}

/******************************************************************************
 * cmp_str - Función de comparación para ordenar strings
 * 
 * Parámetros:
 *   s1, s2 - Strings a comparar
 * 
 * Retorno: Resultado de ft_strcmp
 *****************************************************************************/
int	cmp_str(char *s1, char *s2)
{
	return ft_strcmp(s1, s2);
}

/******************************************************************************
 * test_list_sort - Prueba la función ft_list_sort
 * 
 * Verifica que la lista se ordene correctamente usando una función de
 * comparación (strcmp en este caso).
 *****************************************************************************/
void	test_list_sort(void)
{
	printf(BLUE "\n=== Testing ft_list_sort ===\n" RESET);
	
	t_list *list = NULL;
	
	ft_list_push_front(&list, "delta");
	ft_list_push_front(&list, "alpha");
	ft_list_push_front(&list, "charlie");
	ft_list_push_front(&list, "bravo");
	
	printf("Before sort: ");
	print_list(list);
	
	ft_list_sort(&list, (int (*)())cmp_str);
	
	printf("After sort:  ");
	print_list(list);
	
	if (list && strcmp((char *)list->data, "alpha") == 0 &&
		list->next && strcmp((char *)list->next->data, "bravo") == 0 &&
		list->next->next && strcmp((char *)list->next->next->data, "charlie") == 0 &&
		list->next->next->next && strcmp((char *)list->next->next->next->data, "delta") == 0)
		printf(GREEN "✓\n" RESET);
	else
		printf(RED "✗\n" RESET);
	
	/* Liberar memoria de la lista */
	while (list)
	{
		t_list *tmp = list;
		list = list->next;
		free(tmp);
	}
}

/******************************************************************************
 * free_data - Función de liberación para datos de prueba
 * 
 * Nota: En este caso no liberamos nada porque usamos string literals,
 * pero en uso real debería liberar memoria dinámica.
 *****************************************************************************/
void	free_data(void *data)
{
	(void)data; /* No hacer nada con string literals */
}

/******************************************************************************
 * test_list_remove_if - Prueba la función ft_list_remove_if
 * 
 * Verifica que se eliminen correctamente todos los elementos que coincidan
 * con el criterio de comparación.
 *****************************************************************************/
void	test_list_remove_if(void)
{
	printf(BLUE "\n=== Testing ft_list_remove_if ===\n" RESET);
	
	t_list *list = NULL;
	
	ft_list_push_front(&list, "keep1");
	ft_list_push_front(&list, "remove");
	ft_list_push_front(&list, "keep2");
	ft_list_push_front(&list, "remove");
	ft_list_push_front(&list, "keep3");
	
	printf("Before remove: ");
	print_list(list);
	
	ft_list_remove_if(&list, "remove", (int (*)())cmp_str, free_data);
	
	printf("After remove:  ");
	print_list(list);
	
	/* Verificar que no queden elementos "remove" */
	int has_remove = 0;
	t_list *tmp = list;
	while (tmp)
	{
		if (strcmp((char *)tmp->data, "remove") == 0)
			has_remove = 1;
		tmp = tmp->next;
	}
	
	if (!has_remove && ft_list_size(list) == 3)
		printf(GREEN "✓\n" RESET);
	else
		printf(RED "✗\n" RESET);
	
	/* Liberar memoria de la lista */
	while (list)
	{
		tmp = list;
		list = list->next;
		free(tmp);
	}
}

/******************************************************************************
 * main - Ejecuta todos los tests de funciones bonus
 * 
 * Retorno: 0 (éxito)
 *****************************************************************************/
int	main(void)
{
	printf(BLUE "╔════════════════════════════════════╗\n");
	printf("║       LIBASM BONUS TESTS           ║\n");
	printf("╚════════════════════════════════════╝\n" RESET);
	
	test_atoi_base();
	test_list_push_front();
	test_list_size();
	test_list_sort();
	test_list_remove_if();
	
	printf(BLUE "\n╔════════════════════════════════════╗\n");
	printf("║         TESTS COMPLETED            ║\n");
	printf("╚════════════════════════════════════╝\n" RESET);
	
	return (0);
}
