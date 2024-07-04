// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 10     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "Protheus.ch"
#include "VEIVA620.CH"


#define STR0018 "" // Reaproveitar
#define STR0019 "" // Reaproveitar
#define STR0020 "" // Reaproveitar
#define STR0021 "" // Reaproveitar
#define STR0022 "" // Reaproveitar
#define STR0023 "" // Reaproveitar
#define STR0024 "" // Reaproveitar
#define STR0025 "" // Reaproveitar
#define STR0026 "" // Reaproveitar
#define STR0027 "" // Reaproveitar
#define STR0028 "" // Reaproveitar
#define STR0029 "" // Reaproveitar
#define STR0030 "" // Reaproveitar
#define STR0031 "" // Reaproveitar
#define STR0032 "" // Reaproveitar
#define STR0033 "" // Reaproveitar
#define STR0034 "" // Reaproveitar
#define STR0035 "" // Reaproveitar
#define STR0036 "" // Reaproveitar
#define STR0037 "" // Reaproveitar
#define STR0038 "" // Reaproveitar
#define STR0039 "" // Reaproveitar
#define STR0040 "" // Reaproveitar
#define STR0041 "" // Reaproveitar
#define STR0042 "" // Reaproveitar
#define STR0043 "" // Reaproveitar
#define STR0044 "" // Reaproveitar
#define STR0045 "" // Reaproveitar
#define STR0046 "" // Reaproveitar


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEIVA620 ³ Autor ³ Andre Luis Almeida    ³ Data ³ 21/09/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Operacao CEV - Cadastros/Movimentos/Consultas/Relatorios   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIVA620()

DEFINE MSDIALOG oCentralCEV FROM 000,000 TO 023,030 TITLE STR0001 OF oMainWnd

@ 010,010 BUTTON oCad2 PROMPT (STR0002+" - "+STR0004) OF oCentralCEV SIZE 100,09 PIXEL ACTION FS_EXEC("MATA030")	// SA1 - Clientes - Cadastro
@ 020,010 BUTTON oCad3 PROMPT (STR0002+" - "+STR0005) OF oCentralCEV SIZE 100,09 PIXEL ACTION FS_EXEC("VEICM560")	// VCF - Clientes - Dados Adicionais
@ 030,010 BUTTON oCad4 PROMPT (STR0003) OF oCentralCEV SIZE 100,09 PIXEL ACTION FS_EXEC("VEICA570")					// Pessoas de Contato
@ 040,010 BUTTON oCad5 PROMPT (STR0016) OF oCentralCEV SIZE 100,09 PIXEL ACTION FS_EXEC("VEICA580")					// Frota do Cliente
@ 003,003 TO 052,117 LABEL STR0004 OF oCentralCEV PIXEL

@ 060,010 BUTTON oGer1 PROMPT (STR0007) OF oCentralCEV SIZE 100,09 PIXEL ACTION FS_EXEC("VEICM500")					// Geracao de Agenda
@ 070,010 BUTTON oGer2 PROMPT (STR0008) OF oCentralCEV SIZE 100,09 PIXEL ACTION VEICM550()							// Clientes por Regiao
@ 053,003 TO 082,117 LABEL STR0006 OF oCentralCEV PIXEL

@ 090,010 BUTTON oAbo1 PROMPT (STR0010) OF oCentralCEV SIZE 100,09 PIXEL ACTION FS_CEVABO() 						// Abord. sem Agenda / Satisf./Insatisf.
@ 100,010 BUTTON oAbo2 PROMPT (STR0011) OF oCentralCEV SIZE 100,09 PIXEL ACTION FS_EXEC("VEICM510")					// Registra Abordagem agendada
@ 083,003 TO 112,117 LABEL STR0009 OF oCentralCEV PIXEL

@ 120,010 BUTTON oImp1 PROMPT (STR0013) OF oCentralCEV SIZE 100,09 PIXEL ACTION VEICC500() // Contatos CEV
@ 130,010 BUTTON oImp2 PROMPT (STR0014) OF oCentralCEV SIZE 100,09 PIXEL ACTION VEICM550() // Clientes por Regiao
@ 140,010 BUTTON oImp3 PROMPT (STR0015) OF oCentralCEV SIZE 100,09 PIXEL ACTION VEICR501() // Impressao Ficha CEV
@ 113,003 TO 152,117 LABEL STR0012 OF oCentralCEV PIXEL

DEFINE SBUTTON FROM 156,083 TYPE 2 ACTION (oCentralCEV:End()) ENABLE OF oCentralCEV

ACTIVATE MSDIALOG oCentralCEV CENTER

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_EXEC  ³ Autor ³ Andre Luis Almeida    ³ Data ³ 21/05/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Executa Programa/Funcao com tratamentos do usuario/menu    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_EXEC(cProgExec)
Local acBroSlv := acBrowse
If FindFunction("ChkUserRules")
	If !ChkUserRules(cProgExec,cAcesso,STR0017) // Usuário sem acesso!
		Return()
	EndIf
EndIf
acBrowse := NgAcBrowse(cProgExec)
&(cProgExec+"()")
acBrowse := acBroSlv
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_CEVABO³ Autor ³ Andre Luis Almeida    ³ Data ³ 21/09/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ CEV - Abordagem                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_CEVABO()
Private aCampos := {}
Private aRotina := {{ "P" ,"AxPesqui", 0 , 1},;   	&& Pesquisar
					{ "V" ,"Ml500V", 0 , 2},;     	&& Visualizar
					{ "I" ,"Ml500I", 0 , 3},;     	&& Agendar
					{ "A" ,"Ml500A", 0 , 2},;     	&& Registra Abordagem
					{ "2" ,"Ml5002", 0 , 2},;     	&& 2a. Via
					{ "E" ,"Ml500E", 0 , 5} }  	&& Excluir
Private cCadastro := ""
Private lRefresh := .f.
Inclui := .t.
Altera := .f.
Ml500A("VC1",VC1->(Recno()),2)
Return()