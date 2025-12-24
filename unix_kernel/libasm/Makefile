NAME		= libasm.a
NAME_BONUS	= libasm_bonus.a

SRCS_DIR	= srcs/
BONUS_DIR	= bonus/
OBJS_DIR	= objs/

SRCS		= ft_strlen.s \
			  ft_strcpy.s \
			  ft_strcmp.s \
			  ft_write.s \
			  ft_read.s \
			  ft_strdup.s

BONUS_SRCS	= ft_atoi_base_bonus.s \
			  ft_list_push_front_bonus.s \
			  ft_list_size_bonus.s \
			  ft_list_sort_bonus.s \
			  ft_list_remove_if_bonus.s

OBJS		= $(addprefix $(OBJS_DIR), $(SRCS:.s=.o))
BONUS_OBJS	= $(addprefix $(OBJS_DIR), $(BONUS_SRCS:.s=.o))

NASM		= nasm
NASM_FLAGS	= -f elf64
AR			= ar rcs
RM			= rm -f

TEST		= test_libasm
TEST_BONUS	= test_bonus

.DEFAULT_GOAL := help

help:
	@echo "══════════════════════════════════════════════════════════════════════"
	@echo "  LIBASM - Makefile Help"
	@echo "══════════════════════════════════════════════════════════════════════"
	@echo ""
	@echo "📚 TARGETS PRINCIPALES:"
	@echo "  make all          - Compila la biblioteca estándar (libasm.a)"
	@echo "  make bonus        - Compila con funciones bonus incluidas"
	@echo "  make clean        - Elimina archivos objeto (.o)"
	@echo "  make fclean       - Elimina objetos y ejecutables"
	@echo "  make re           - Recompila todo desde cero (fclean + all)"
	@echo ""
	@echo "🧪 TESTING:"
	@echo "  make test         - Compila y ejecuta tests principales"
	@echo "  make test_bonus   - Compila y ejecuta tests bonus"
	@echo ""
	@echo "📋 FUNCIONES IMPLEMENTADAS:"
	@echo "  Mandatorias:"
	@echo "    - ft_strlen     - Calcula longitud de cadena"
	@echo "    - ft_strcpy     - Copia cadena"
	@echo "    - ft_strcmp     - Compara cadenas"
	@echo "    - ft_write      - Escribe en descriptor de archivo"
	@echo "    - ft_read       - Lee de descriptor de archivo"
	@echo "    - ft_strdup     - Duplica cadena (malloc)"
	@echo ""
	@echo "  Bonus:"
	@echo "    - ft_atoi_base          - Conversión string a int con base"
	@echo "    - ft_list_push_front    - Añade elemento al inicio de lista"
	@echo "    - ft_list_size          - Cuenta elementos de lista"
	@echo "    - ft_list_sort          - Ordena lista enlazada"
	@echo "    - ft_list_remove_if     - Elimina elementos según condición"
	@echo ""
	@echo "🔧 HERRAMIENTAS:"
	@echo "  Ensamblador: $(NASM) $(NASM_FLAGS)"
	@echo "  Archivador:  $(AR)"
	@echo ""
	@echo "📖 EJEMPLO DE USO:"
	@echo "  make all && make test         # Compila y prueba funciones básicas"
	@echo "  make bonus && make test_bonus # Compila y prueba con bonus"
	@echo ""
	@echo "══════════════════════════════════════════════════════════════════════"
	@echo ""

all: $(NAME)

$(NAME): $(OBJS_DIR) $(OBJS)
	@$(AR) $(NAME) $(OBJS)
	@echo "✅ libasm.a created"

$(OBJS_DIR):
	@mkdir -p $(OBJS_DIR)

$(OBJS_DIR)%.o: $(SRCS_DIR)%.s
	@$(NASM) $(NASM_FLAGS) $< -o $@
	@echo "🔧 Compiled: $<"

$(OBJS_DIR)%.o: $(BONUS_DIR)%.s
	@$(NASM) $(NASM_FLAGS) $< -o $@
	@echo "🔧 Compiled: $<"

bonus: $(OBJS_DIR) $(OBJS) $(BONUS_OBJS)
	@$(AR) $(NAME) $(OBJS) $(BONUS_OBJS)
	@echo "✅ libasm.a created with bonus"

test: $(NAME)
	@gcc -Wall -Wextra -Werror tests/main.c -L. -lasm -I. -o $(TEST)
	@echo "✅ Test executable created"
	@./$(TEST)

test_bonus: bonus
	@gcc -Wall -Wextra -Werror tests/main_bonus.c -L. -lasm -I. -o $(TEST_BONUS)
	@echo "✅ Test bonus executable created"
	@./$(TEST_BONUS)

clean:
	@$(RM) -r $(OBJS_DIR)
	@echo "🧹 Object files removed"

fclean: clean
	@$(RM) $(NAME)
	@$(RM) $(TEST) $(TEST_BONUS)
	@echo "🧹 Executables removed"

re: fclean all

.PHONY: all bonus test test_bonus clean fclean re help
