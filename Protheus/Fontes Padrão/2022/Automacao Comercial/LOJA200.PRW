#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA200.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³ LOJA200  ³ Autor ³ Cesar Eduardo Valadao ³ Data ³15/04/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cadastro do Resumo de Reducao Z                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaLoja                                                   ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LOJA200()

Local aRotAdic   := {}       				 	// Array aRotina Adicional 
Local aRet       := {}						 	// Array de retorno do PE LJ7200ADBT  
Local lLj7200AdBt:= ExistBlock( "LJ7200ADBT" ) 	// Verifica se existe o ponto de entrada LJ7200ADBT 
Local nCont      := 0                        	// Contador de for
  
Private nSaveSx8 := GetSx8Len()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada que permite adicionar opcoes no cadastro do resumo de reducao Z³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lLj7200AdBt
	LjGrvLog( NIL, " Antes da execução do P.E. LJ7200AdBT")
	aRet:= ExecBlock("LJ7200ADBT",.F.,.F.)
	LjGrvLog( NIL, " Depois da execução do P.E. LJ7200AdBT",aRet)
	If ValType(aRet) == "A"
		For nCont := 1 to Len(aRet)
			If Len(aRet[nCont]) == 6	// Somente adiciona se o tamanho for compativel	a estrutura do aRotina
				aAdd(aRotAdic ,aRet[nCont])
			EndIf
	    Next nCont
	EndIf
EndIf
	
AxCadastro("SFI",OemToAnsi(STR0001),,"LJ200TudOk()", aRotAdic )	//"Resumo Redu‡„o Z"  

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³LJ200TudOk³ Autor ³ Cesar Eduardo Valadao ³ Data ³15/04/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se os campos digitados estao Ok                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LJ200TudOk()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaLoja                                                   ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LJ200TudOk()
Local nSaveSX8 	:= GetSX8Len()				//Ultimo numero do SX8
Local lRet		:= .T.						//Retorno da Funcao
Local lIntegRm  := SuperGetMv( "MV_LJRMBAC",, .F.) //Verifica integracao RM ativa
Local lLjNfPafEcf:= LjNfPafEcf(SM0->M0_CGC)
Local cHrRedZ	:= "" //Hora da Reducao

If INCLUI
	DbSetOrder( 1 )

	If MsSeek( xFilial() + DToS( M->FI_DTMOVTO ) + M->FI_PDV + M->FI_NUMREDZ )
		Help( " ", 1, "JAGRAVADO" )
		lRet := .F.
	EndIf
EndIf

If lRet
	//Se integracao RM, altera status da Reducao para que seja enviada na integracao
	If lIntegRm																
		If INCLUI //Inclusao
			cHrRedZ := StrTran(Time(), ":", "")
			cHrRedZ += Padr(cHrRedZ, 6, "0")
			 					
			M->FI_DTREDZ := dDataBase
			M->FI_HRREDZ := cHrRedZ
			M->FI_SITUA  := "RX"
		ElseIf ALTERA //Alteracao			
			M->FI_SITUA  := "RX"
		EndIf							
	EndIf
	
	If lLjNfPafEcf
		M->FI_PAFMD5 :=  STxPafMd5("SFI")
		M->FI_MD5TRIB := STxPafMd5("SFI","","2")
	EndIf
	
	While GetSx8Len() > nSaveSX8
		ConfirmSX8()
	EndDo		
Endif

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LJ200NUM  ºAutor  ³Andre Veiga         º Data ³  10/12/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para ser utilizada como inicializador padrao do campoº±±
±±º          ³FI_NUMERO                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJA200 (X3_RELACAO)                                        º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LJ200NUM(dData)
Local cRetorno

SFI->(dbSetOrder(1))
If SFI->(dbSeek(xFilial("SFI")+DTOS(dData)))
	cRetorno := SFI->FI_NUMERO
Else
	cRetorno := GetSx8Num("SFI","FI_NUMERO")
Endif

Return cRetorno

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³ LJ200Inc ³ Autor ³ Cesar Eduardo Valadao ³ Data ³17/06/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Permite a inclusao do Resumo Reducao Z manual              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Front Loja                                                 ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LJ200Inc
Local cArea := Alias()
// Variaveis utilizadas pelo AXInclui
Private cCadastro := STR0001	//"Resumo Redução Z"
Private lRefresh  := .T.
Private INCLUI    := .T.

dbSelectArea("SFI")
SFI->(dbSetOrder(1))
AxInclui("SFI", Recno(), 3,,,,"LJ200TudOk()")
dbSelectArea(cArea)

Return NIL
