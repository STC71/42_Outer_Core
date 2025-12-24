/******************************************************************************
 * LIBASM - Test Suite para Funciones Obligatorias
 * 
 * Este programa realiza pruebas comprehensivas de todas las funciones
 * obligatorias implementadas en assembly, comparándolas con sus
 * equivalentes de la biblioteca estándar de C.
 *
 * Funciones probadas:
 *   - ft_strlen:  Longitud de cadena
 *   - ft_strcpy:  Copia de cadena
 *   - ft_strcmp:  Comparación de cadenas
 *   - ft_write:   Escritura en descriptor de archivo
 *   - ft_read:    Lectura desde descriptor de archivo
 *   - ft_strdup:  Duplicación de cadena en heap
 *****************************************************************************/

#include "../libasm.h"
#include <stdio.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include <stdlib.h>

/* Códigos de color ANSI para salida formateada */
#define GREEN "\033[0;32m"
#define RED "\033[0;31m"
#define BLUE "\033[0;34m"
#define YELLOW "\033[0;33m"
#define RESET "\033[0m"

/******************************************************************************
 * test_strlen - Prueba la función ft_strlen
 * 
 * Compara el resultado de ft_strlen con strlen de la biblioteca estándar
 * para varias cadenas de prueba de diferentes longitudes.
 *****************************************************************************/
void	test_strlen(void)
{
	printf(BLUE "\n=== Testing ft_strlen ===\n" RESET);
	
	char *tests[] = {"Hello", "", "42", "This is a longer string", NULL};
	for (int i = 0; tests[i]; i++)
	{
		size_t expected = strlen(tests[i]);
		size_t result = ft_strlen(tests[i]);
		printf("ft_strlen(\"%s\"): %zu ", tests[i], result);
		if (result == expected)
			printf(GREEN "✓\n" RESET);
		else
			printf(RED "✗ (expected %zu)\n" RESET, expected);
	}
}

/******************************************************************************
 * test_strcpy - Prueba la función ft_strcpy
 * 
 * Verifica que ft_strcpy copie correctamente cadenas de diferentes
 * longitudes, comparando el resultado con strcpy.
 *****************************************************************************/
void	test_strcpy(void)
{
	printf(BLUE "\n=== Testing ft_strcpy ===\n" RESET);
	
	char *tests[] = {"Hello", "", "42", "Copy this!", NULL};
	for (int i = 0; tests[i]; i++)
	{
		char dst1[100] = {0};
		char dst2[100] = {0};
		strcpy(dst1, tests[i]);
		ft_strcpy(dst2, tests[i]);
		printf("ft_strcpy(dst, \"%s\"): \"%s\" ", tests[i], dst2);
		if (strcmp(dst1, dst2) == 0)
			printf(GREEN "✓\n" RESET);
		else
			printf(RED "✗ (expected \"%s\")\n" RESET, dst1);
	}
}

/******************************************************************************
 * test_strcmp - Prueba la función ft_strcmp
 * 
 * Compara pares de cadenas y verifica que ft_strcmp produzca el mismo
 * resultado que strcmp (mismo signo de retorno).
 *****************************************************************************/
void	test_strcmp(void)
{
	printf(BLUE "\n=== Testing ft_strcmp ===\n" RESET);
	
	struct {
		char *s1;
		char *s2;
	} tests[] = {
		{"Hello", "Hello"},
		{"Hello", "World"},
		{"", ""},
		{"abc", "abd"},
		{"test", "tes"},
		{NULL, NULL}
	};
	
	for (int i = 0; tests[i].s1; i++)
	{
		int expected = strcmp(tests[i].s1, tests[i].s2);
		int result = ft_strcmp(tests[i].s1, tests[i].s2);
		printf("ft_strcmp(\"%s\", \"%s\"): %d ", tests[i].s1, tests[i].s2, result);
		if ((expected == 0 && result == 0) ||
			(expected < 0 && result < 0) ||
			(expected > 0 && result > 0))
			printf(GREEN "✓\n" RESET);
		else
			printf(RED "✗ (expected %d)\n" RESET, expected);
	}
}

/******************************************************************************
 * test_write - Prueba la función ft_write
 * 
 * Verifica que ft_write escriba correctamente a stdout y maneje errores
 * apropiadamente (descriptor inválido).
 *****************************************************************************/
void	test_write(void)
{
	printf(BLUE "\n=== Testing ft_write ===\n" RESET);
	
	char *msg = "Test write\n";
	printf("ft_write(1, \"Test write\\n\", 11): ");
	ssize_t result = ft_write(1, msg, strlen(msg));
	if (result == (ssize_t)strlen(msg))
		printf(GREEN "✓\n" RESET);
	else
		printf(RED "✗ (returned %zd)\n" RESET, result);
	
	/* Probar manejo de errores */
	errno = 0;
	result = ft_write(-1, msg, strlen(msg));
	printf("ft_write(-1, msg, len) [error test]: ");
	if (result == -1 && errno != 0)
		printf(GREEN "✓ (errno = %d)\n" RESET, errno);
	else
		printf(RED "✗\n" RESET);
}

/******************************************************************************
 * test_read - Prueba la función ft_read
 * 
 * Crea un archivo temporal, lee su contenido con ft_read y verifica
 * que los datos se lean correctamente. También prueba el manejo de errores.
 *****************************************************************************/
void	test_read(void)
{
	printf(BLUE "\n=== Testing ft_read ===\n" RESET);
	
	/* Crear archivo de prueba */
	int fd = open("/tmp/libasm_test.txt", O_CREAT | O_WRONLY | O_TRUNC, 0644);
	write(fd, "Hello from file!", 16);
	close(fd);
	
	/* Leer con ft_read */
	fd = open("/tmp/libasm_test.txt", O_RDONLY);
	char buf[100] = {0};
	ssize_t result = ft_read(fd, buf, 16);
	close(fd);
	unlink("/tmp/libasm_test.txt");
	
	printf("ft_read(fd, buf, 16): \"%s\" ", buf);
	if (result == 16 && strcmp(buf, "Hello from file!") == 0)
		printf(GREEN "✓\n" RESET);
	else
		printf(RED "✗\n" RESET);
	
	/* Probar manejo de errores */
	errno = 0;
	result = ft_read(-1, buf, 10);
	printf("ft_read(-1, buf, 10) [error test]: ");
	if (result == -1 && errno != 0)
		printf(GREEN "✓ (errno = %d)\n" RESET, errno);
	else
		printf(RED "✗\n" RESET);
}

/******************************************************************************
 * test_strdup - Prueba la función ft_strdup
 * 
 * Verifica que ft_strdup cree correctamente copias de cadenas en memoria
 * dinámica y que las copias sean independientes del original.
 *****************************************************************************/
void	test_strdup(void)
{
	printf(BLUE "\n=== Testing ft_strdup ===\n" RESET);
	
	char *tests[] = {"Hello", "", "Duplicate this!", NULL};
	for (int i = 0; tests[i]; i++)
	{
		char *dup = ft_strdup(tests[i]);
		printf("ft_strdup(\"%s\"): \"%s\" ", tests[i], dup);
		if (dup && strcmp(tests[i], dup) == 0 && dup != tests[i])
			printf(GREEN "✓\n" RESET);
		else
			printf(RED "✗\n" RESET);
		free(dup);
	}
}

/******************************************************************************
 * main - Ejecuta todos los tests de funciones obligatorias
 * 
 * Retorno: 0 (éxito)
 *****************************************************************************/
int	main(void)
{
	printf(BLUE "╔════════════════════════════════════╗\n");
	printf("║     LIBASM MANDATORY TESTS         ║\n");
	printf("╚════════════════════════════════════╝\n" RESET);
	
	test_strlen();
	test_strcpy();
	test_strcmp();
	test_write();
	test_read();
	test_strdup();
	
	printf(BLUE "\n╔════════════════════════════════════╗\n");
	printf("║         TESTS COMPLETED            ║\n");
	printf("╚════════════════════════════════════╝\n" RESET);
	
	return (0);
}
