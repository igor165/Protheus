#INCLUDE "PROTHEUS.CH"
#INCLUDE "tdsBirt.CH"
#INCLUDE "CTBR817.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CTBR817  ³ Autor ³ Jonathan Gonzalez     ³ Data ³ 15.12.14   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imp. del relatorio flujo de caja en formato BIRT             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTBR817()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³jonathan glz³08/09/2015³TTHAMD³Se cambia la forma de imprimir el archivo ³±±
±±³            ³          ³      ³Termino Auxiliares para que no permita    ³±±
±±³            ³          ³      ³imprimir archivo mayoresa 2 mil caracteres³±±
±±³Jonathan Glz³30/06/2017³MMI-  ³Se cambia el grupo de preguntas se crean  ³±±
±±³            ³          ³  6119³los grupos CTBR817A y CTBR817B, se cambia ³±±
±±³            ³          ³      ³las validaciones y el titulo del reporte. ³±±
±±³            ³          ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION CTBR817()
	Local cPerg := "CTR817A"

	Private nMvPAR01 := 0
	Private nMvPAR02 := 0

	Help(" ",1,STR0054,,STR0053,1,0)  //Mensagem de descontinuacao e bloqueio a partir de 01/10/2022.

	If Date() >= CTOD("01/10/2022")
		Return
	Endif

		//chama a tela de perguntas
		Pergunte(cPerg,.T.)
		nMvPAR01 := MV_PAR01
		nMvPAR02 := MV_PAR02

		if nMvPAR01 == 1
			If nMvPAR02 == 2
                                                      //DEMOSTRACION DEL FLUJO DE CAJA " - Variacion: SI" " - Metodo: Indirecto"
				DEFINE REPORT oRPT NAME CTBR817 TITLE STR0002 + STR0049 + STR0052 EXCLUSIVE
				ACTIVATE REPORT oRPT
			Else
                                                      //DEMOSTRACION DEL FLUJO DE CAJA " - Variacion: SI" " - Metodo: Directo"
				DEFINE REPORT oRPT NAME CTBR817a TITLE STR0002 + STR0049 + STR0051 EXCLUSIVE
				ACTIVATE REPORT oRPT
			EndIf
		else
			If nMvPAR02 == 2
                                                      //DEMOSTRACION DEL FLUJO DE CAJA " - Variacion: NO" " - Metodo: Indirecto"
				DEFINE REPORT oRPT NAME CTBR817v TITLE STR0002 + STR0050 + STR0052 EXCLUSIVE
				ACTIVATE REPORT oRPT
			Else
                                                       //DEMOSTRACION DEL FLUJO DE CAJA " - Variacion: NO" " - Metodo: Directo"
				DEFINE REPORT oRPT NAME CTBR817av TITLE STR0002 + STR0050 + STR0051 EXCLUSIVE
				ACTIVATE REPORT oRPT
			EndIf
		endif
RETURN
