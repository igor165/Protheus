#INCLUDE "TMKXFUNE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMKDEF.CH" 
#INCLUDE  "FWMVCDEF.CH"

Static __lF3Contato := .F.
Static __aF3SUSRet 	:= {}
Static __aRamal		:= {}
Static _lTmkXCTET		:= ExistBlock("TMKXCTET")
Static _lTkContQry	:= ExistBlock("TKCONTQRY")		//Ponto de entrada utilizado para filtrar os contatos das entidades.
Static _lTkEntUsr		:= ExistBlock("TKENTUSR")
Static _lTkEntBTA		:= ExistBlock("TKENTBTA")
Static _lTkVlSele		:= ExistBlock("TKVLSELE")
Static _lTkBusCon		:= ExistBlock("TKBUSCON")

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTMKPO     บAutor  ณ Vendas Clientes    บ Data ณ  21/07/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCadastro de Prospects na escolha de clientes via F3         บฑฑ
ฑฑบ          ณpela consulta "CLT" - no arquivo SXB (Consulta de clientes) บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณCALL CENTER                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function TMKPO()        

Local lRet := .F.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณImpede a sele็ใo de Prospects no atendimento TeleCobran็a.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nFolder == 1 .AND. TkGetTipoAte() == "3" //Telecobranca
	Help( "", 1, "TKSELPRO" ) // "A sele็ใo de Prospects nใo ้ vแlida para o Atendimento TeleCobranca."
	Return(lRet)
ElseIf nFolder == 3 
	Help( "", 1, "TKSELPRO" )
	Return(lRet)
EndIf

SETAPILHA()

lGotFocus := .F. 	// Desliga o gotfocus do oCliTmk

cAliasOld:= Alias()

DbSelectarea("SUS")
If Conpad1(NIL,NIL,NIL,"TMP",NIL,.F.,.F.)
	If Type("aCpoRet") <> "U"
		__aF3SUSRet := {aCpoRet[1],aCpoRet[2]}
	EndIf
	lProspect := .T.
ElseIf lProspect == .T. .AND. !Empty(M->UA_CLIENTE)
	lProspect := .T.	
Else
	lProspect := .F.
EndIf

DbSelectarea(cAliasOld)

Return(lProspect)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTkF3IsSUS บAutor  ณ CRM FATURANENTO    บ Data ณ  28/06/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna Variavel Statica __lF3SUS para a fun็ใo TkCliente   บฑฑ
ฑฑบ          ณdefinir se vai filtrar cliente ou prospect para carregar no บฑฑ
ฑฑบ          ณatendimento Televendas     								  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณCALL CENTER                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function TkF3SUSData()
Return(__aF3SUSRet)

Function TkF3SUSClear() 
	aSize(__aF3SUSRet,0)
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTMKIPO    บAutor  ณ Vendas Clientes    บ Data ณ  21/07/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCadastro de Prospects na escolha de clientes via F3         บฑฑ
ฑฑบ          ณpela consulta "CLT" - no arquivo SXB (Consulta de clientes) บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณCALL CENTER                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function TMKIPO()        

Local cAliasOld	:= Alias()
Local lRet 		:= .F.
Local nOpca 	:= 0
Local lIncluiOld:= INCLUI	//guarda o valor da variavel INCLUI

INCLUI := .T.

DbSelectarea("SUS")
SETAPILHA()

nOpcA := FWExecView( STR0060, 'TMKA260', 3,, { || .T. } ) //"Incluir"

If nOpcA <> 1
	lProspect := .F.
Endif

DbSelectarea(cAliasOld)
INCLUI := lIncluiOld	//restaura o valor original da variavel INCLUI

Return(lRet)        

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTkHoraOk  บAutor  ณVendas Clientes     บ Data ณ  14/10/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao de validacao das horas informadas pelo usuario.      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParam.    ณcHora  - Hora que devera ser validada                       บฑฑ
ฑฑบ          ณcIni   - String da hora inicial do intervalo a ser validada บฑฑ
ฑฑบ          ณcFim   - String da hora final do intervalo a ser validada   บฑฑ
ฑฑบ          ณlMens  - Define se a mensagem de hora invalida sera exibida บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function TkHoraOk(cValor, cIni, cFim, lMens)

Local lRet	:= .F.			// Retorno logico da funcao
Local nHor	:= 0			// Hora a ser validade
Local nMin	:= 0			// Minuto a ser validado
Local nSeg	:= 0			// Segundo a ser validado
Local nHIni	:= 0			// Hora inicial do intervalo
Local nMIni	:= 0			// Minuto inicial do intervalo
Local nSIni	:= 0			// Segundo inicial do intervalo
Local nHFim	:= 0			// Hora final do intervalo
Local nMFim	:= 0			// Minuto final do intervalo
Local nSFim	:= 0			// Segundo final do intervalo
Local cVar	:= ReadVar()	// Nome da variavel da enchoice

Default cValor	:= &(ReadVar())
Default cIni	:= "00:00:00"
Default cFim	:= "23:59:59"
Default lMens	:= .T.

nHor	:= Val(SubStr(cValor,1,2))
nMin	:= Val(SubStr(cValor,4,2))
nSeg	:= Val(SubStr(cValor,7,2))
cValor	:= StrZero(nHor,2) + ":" + StrZero(nMin,2) + ":" + StrZero(nSeg,2)
If !Empty(cVar)
	&cVar	:= cValor
Endif

nHIni	:= Val(SubStr(cIni,1,2))
nMIni	:= Val(SubStr(cIni,4,2))
nSIni	:= Val(SubStr(cIni,7,2))

nHFim	:= Val(SubStr(cFim,1,2))
nMFim	:= Val(SubStr(cFim,4,2))
nSFim	:= Val(SubStr(cFim,7,2))

If	(nHor >= nHIni .AND. nHor <= nHFim) .AND.;
	(nMin >= nMIni .AND. nMin <= nMFim) .AND.;
	(nSeg >= nSIni .AND. nSeg <= nSFim)
	
	lRet := .T.
Else
	If lMens
		Help(" ",1,"TKHORANOK",,cIni + " - " + cFim,4,0)
	Endif
Endif

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTkHoraCompบAutor  ณVendas Clientes     บ Data ณ  14/10/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao de comparacao entre dois valores de horas.           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParam.    ณcIni  - Hora inicial para compraracao.                      บฑฑ
ฑฑบ          ณcFim  - Hora final para compraracao.                        บฑฑ
ฑฑบ          ณcExpr - Expressao obrigatoria de comparacao das horas.      บฑฑ
ฑฑบ          ณlMens - Define se serแ exibida a mensagem de aviso.         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function TkHoraComp(cIni, cFim, cExpr, cMens)

Local lRet	:= .F.
Local nHor	:= 0
Local nMin	:= 0
Local nSeg	:= 0

Default cIni	:= "00:00:00"
Default cFim	:= "23:59:59"
Default cExpr	:= "=="
Default cMens	:= ""

IF !Empty(StrTran(cIni,":","")) .AND. !Empty(StrTran(cFim,":",""))
	nHor := Val(SubStr(cIni,1,2))
	nMin := Val(SubStr(cIni,4,2))
	nSeg := Val(SubStr(cIni,7,2))
	cIni := StrZero(nHor,2) + ":" + StrZero(nMin,2) + ":" + StrZero(nSeg,2)
	nHor := Val(SubStr(cFim,1,2))
	nMin := Val(SubStr(cFim,4,2))
	nSeg := Val(SubStr(cFim,7,2))
	cFim := StrZero(nHor,2) + ":" + StrZero(nMin,2) + ":" + StrZero(nSeg,2)
	Do Case
		Case cExpr $ "==,="
			If cIni == cFim .OR. cIni = cFim
				lRet := .T.
			Endif
		
		Case cExpr $ "<>,!=,#"
			If cIni <> cFim
				lRet := .T.
			Endif
		
		Case cExpr == "<"
			If cIni < cFim
				lRet := .T.
			Endif
		
		Case cExpr == "<="
			If cIni <= cFim
				lRet := .T.
			Endif
		
		Case cExpr == ">"
			If cIni > cFim
				lRet := .T.
			Endif
		
		Case cExpr == ">="
			If cIni >= cFim
				lRet := .T.
			Endif
	Endcase
	
	If !Empty(cMens) .AND. !lRet
		Help(" ",1,"TKHORACOMP",,cMens,4,0)
	Endif
	
Else
	// Neste caso uma das duas horas estao vazias
	lRet := .T.
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTKGrvSUV  บAutor  ณVendas Clientes     บ Data ณ  08/01/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza o SUV quando:                                      บฑฑ
ฑฑบ          ณ1 - Houver atualizacao pelo SIGXTEL - Integracao com CTI    บฑฑ
ฑฑบ          ณ2 - Quando o Usuario executar as rotinas de:                บฑฑ
ฑฑบ          ณ     a) Atendimento                                         บฑฑ
ฑฑบ          ณ     b) Agenda                                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CALL CENTER                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function TkGrvSUV(cUsuario, cRotina)

Local cRamal		:= ""
Local aUser		:= {}
Local cFilSUV		:= xFilial("SUV")

If Empty( __aRamal ) .Or. __aRamal[1] <> cUsuario
	PswOrder(1)
	PswSeek(cUsuario) 
	aUser:= PswRet(1)
	If Len(aUser) > 0 
		cRamal := aUser[1][20]
	Endif
	__aRamal := { cUsuario, cRamal }
Else
	cRamal := __aRamal[2]
EndIf

DbSelectArea("SUV") 
DbSetOrder(1)
If DbSeek(cFilSUV + cUsuario)
    If SimpleLock()
		//Destrava o registro do SimpleLock() para fazer a altera็ใo
		RecLock("SUV")
		MsUnlock()
		
		RecLock("SUV",.F.)
		UV_FILIAL  := cFilSUV
		UV_USUARIO := cUsuario
		UV_ROTINA  := cRotina
		UV_RAMAL   := cRamal
		UV_HRINI   := Time()
		DbCommit()
		MsUnlock()
	EndIf
Else
	RecLock("SUV",.T.)
	UV_FILIAL  := cFilSUV
	UV_USUARIO := cUsuario
	UV_ROTINA  := cRotina
	UV_RAMAL   := cRamal
	UV_HRINI   := Time()
	DbCommit()
	MsUnlock()
Endif

SimpleLock()

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออหออออออออออออออออออออหออออออหอออออออออออออปฑฑ
ฑฑบPrograma  ณTkSelEnt   บAutor  บVendas Clientes     บData  บ  11/18/04   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออสออออออออออออออออออออสออออออสอออออออออออออนฑฑ
ฑฑบDescricao ณSelecao do contato atraves de uma entidade. Preenche o       บฑฑ
ฑฑบ          ณcabecalho do atendimento com os dados do contato e entidade, บฑฑ
ฑฑบ          ณe alimenta os folders de Telemarketing, Televendas e  	   บฑฑ
ฑฑบ          ณTelecobranca a partir da selecao.						  	   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CALL CENTER TELEMARKETING                                   บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function TkSelEnt(lHelpDesk)

Local aArea		:= GetArea()					// Salva a area atual
Local aEntidades	:= {}							// Contem as entidades da tabela T5 (Entidades do contato)
Local aEntCNPJ	:= {}							// Contem as Entidades Retornadas pela Pesquisa por CNPJ
Local lSelEnt		:= .F. 							// Indica se o usuario selecionou a entidade a partir do CNPJ
Local aOpcoes		:= {}		         			// Contem as entidades da tabela T5 (Radio)
Local aHeader		:= {}							// aHeader do Contato
Local aColsCont	:= {}			   				// aCols do Contato
Local AcolsBkp	:= {}						    // aCols para c๓pia do acols original
Local aObrigat	:= {}							// Campos obrigatorios do contato
Local aTamCpos	:= TkEntEstru()					// Tamanho dos campos das entidades utilizadas
Local nI			:= 0							// Contador
Local nUsado		:= 0							// Contador para o Acols/Aheader
Local nTamA1_COD	:= GetSX3Cache("A1_COD","X3_TAMANHO")			// Tamanho do campo A1_COD
Local nTamA1_CGC	:= GetSX3Cache("A1_CGC","X3_TAMANHO")			// Tamanho do campo A1_CGC
Local lPls			:= GetNewPar("MV_PLSATIV",.F.)  // Identifica se a integracao com o Modulo de Plano de Saude Esta Ativa
Local cCodigo 	:= Space(nTamA1_COD)			// Codigo da entidade
Local cLoja		:= Space(GetSX3Cache("A1_LOJA","X3_TAMANHO"))	// Loja da Entidade
Local cCNPJ		:= Space(nTamA1_CGC)			// CNPJ da Entidade
Local nOpAlias	:= 1							// Variavel com a opcao selecionada da entidade para o F3 - Default 1 = SA1
Local nOpcA		:= 0							// Opcao ao confirmar a tela de selecao de entidades
Local nPContato	:= 0							// Posicao do Acols em que se encontra o codigo do contato
Local cEntidade	:= ""							// Alias da Entidade Selecionada
Local cChave		:= ""							// Codigo e loja da entidade selecionada
Local cContato	:= ""							// Codigo do contato relacionado com a entidade
Local cContTmp	:= ""							// Codigo do contato auxiliar para montagem da tela
Local cNome		:= ""							// Nome da Entidade
Local cFantasia	:= ""							// Nome Fantasia da Entidade
Local cEndereco	:= ""							// Endereco da Entidade
Local cBairro		:= ""							// Bairro da Entidade
Local cCidade		:= ""							// Cidade da Entidade
Local cEstado		:= ""							// EStado da Entidade
Local cCEP			:= ""							// CEP da Entidade
Local cTelefone	:= ""							// Telefone da Entidade
Local nLenSX8		:= GetSX8Len()					// Posicao atual na pilha de sequenciais de codigos
Local nPCodCont	:= 0							// Posicao do campo U5_CODCONT no aCols
Local nPRefCont	:= 0							// Posicao do campo REFCONT no aCols
Local cCntFRes	:= ""							// Fone residencial do contato
Local cCntFCel	:= ""							// Celular do contato
Local cCntFFax	:= ""							// Fax do contato
Local cCntFCom1	:= ""							// Fone comercial 1 do contato
Local cCntFCom2	:= ""							// Fone comercial 2 do contato
Local cCntMail	:= ""							// Email do contato
Local cCntCargo	:= ""							// Cargo do contato
Local cCposEsp	:= ""							// Campos adicionais da getdados
Local cCposNao	:= ""							// Campos que nao devem constar na getdados
Local cReadVar	:= ReadVar()					// Armazena o nome do campo que acionou a consulta
Local lAlteraEnt	:= .F.							// Se o operador pode ou nใo alterar a entidade
Local cSearch		:= Space(60)					// Texto da procura
Local nPos			:= 0							// Posicionador temporแrio
Local lInCont		:= .T.							// Indica se o usuario tem permissใo para incluir mais de um contato.
Local aAlterSU5	:= {}					  		// Contem todos os campos q o usuario tem permissao para alterar
Local aTamCodLj	:= {}							// Tamanho do codigo
Local bConf		:= Nil							// Bloco de confirma
Local cConfTmk	:= ""							// Configuracao TMK
Local cAux			:= ""							// Variแvel auxiliar
Local cFilSX5		:= xFilial("SX5")
Local cTipoAte	:= TkGetTipoAte()
//Objetos
Local oDlgEnt			:= NIL						// Tela
Local oGetSU5			:= NIL						// NewGetDados do SU5
Local oEntidade		:= NIL						// Objeto Radio na selecao de entidades
Local oCodigo			:= NIL						// Objeto Get para o codigo da entidade
Local oLoja			:= NIL						// Objeto Get para a loja da entidade
Local oNome			:= NIL						// Objeto Get para o nome da entidade
Local oFantasia		:= NIL						// Objeto Get para o nome fantasia da entidade
Local oEndereco		:= NIL						// Objeto Get para o endereco da entidade
Local oBairro			:= NIL						// Objeto Get para o bairro da entidade
Local oCidade			:= NIL						// Objeto Get para a cidade da entidade
Local oEstado			:= NIL						// Objeto Get para o estado da entidade
Local oCEP				:= NIL						// Objeto Get para o CEP da entidade
Local oTelefone		:= NIL						// Objeto Get para o telefone da entidade
Local oBtnInc			:= NIL						// Objeto Button para inclusao de entidades
Local oBtnAlt			:= NIL						// Objeto Button para alteracao de entidades
Local oCntFRes		:= NIL						// Objeto Get para o telefone residencial do contato
Local oCntFCel		:= NIL						// Objeto Get para o celular do contato
Local oCntFFax		:= NIL						// Objeto Get para o fax do contato
Local oCntFCom1		:= NIL						// Objeto Get para o telefone comercial 1 do contato
Local oCntFCom2		:= NIL						// Objeto Get para o telefone comercial 2 do contato
Local oCntMail		:= NIL						// Objeto Get para o email do contato
Local oCntCargo		:= NIL						// Objeto Get para o cargo do contato
Local oCNPJ			:= NIL						// Objeto Get para o CNPJ
Local oSearch			:= NIL						// Objeto Get para a procura
Local oFolder			:= NIL						// Folder com as 2 opcoes de pesquisa de contatos
Local oComboTpPesq	:= NIL
Local cBuscaDireta	:= Space(100)
Local oBtBuscar		:= NIL
Local oListContatos	:= NIL
Local aContatos		:= {}
Local cOpcCombo		:= ""
Local nFolder			:= 0						// Numero da aba utilizada
Local aColsIni		:= {}
Local aPDFields		:= {}
Local aPDCols		:= {}

Default lHelpDesk := .F.

If "TMKR" $ FunName()	//Chama a consulta padrใo, quando for executado atrav้s de qualquer relat๓rio personalizแvel.
	lRet := ConPad1(,,,"SU5")
	Return(lRet)
EndIf

__lF3Contato := .T.

SaveInter()

INCLUI := .T.

SXB->(DbSetOrder(1))
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCarrega as entidades utilizadas na tabela T5.    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
SX5->(DbSetOrder(1))
SX5->(DbSeek(cFilSX5 + "T5",.T.))
While SX5->(! Eof()) .AND. (cFilSX5 == SX5->X5_FILIAL) .AND. (SX5->X5_TABELA == "T5")
	If SXB->(DbSeek(PadR(AllTrim(SX5->X5_CHAVE),Len(SXB->XB_ALIAS))))
		If AllTrim(SX5->X5_CHAVE) <> "BA1"
			Aadd(aEntidades,{	TRIM(SX5->X5_CHAVE),TRIM(SX5->(X5Descri()))})
		ElseIf lPls
			Aadd(aEntidades,{	TRIM(SX5->X5_CHAVE),TRIM(SX5->(X5Descri()))})
		EndIf
	EndIf
	SX5->(DbSkip())
EndDo
                        
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe nao existir nenhuma entidade, nao executa ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Len(aEntidades) == 0
	MsgBox(STR0001,STR0005)//("Aten็ใo","Pelo menos uma entidade deve existir na tabela T5 para que o relacionamento para ser realizado. Contate o administrador do sistema.")
	RestArea(aArea)
	Return(.F.)
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se o operador pode ou nใo alterar a entidade.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If (SubStr(SU7->U7_CFGBTN,12,1) == "1" .Or. Empty(SubStr(SU7->U7_CFGBTN,12,1)))
	lAlteraEnt := .T.
EndIf
	
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณIndexa o array pela descricao dos arquivos.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aEntidades:= ASort(aEntidades,,,{|x,y| x[2] < y[2]})

/*
 ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 ณConteudo do array aEntidade ณ
 ณ                            ณ
 ณSA1 - Cliente               ณ
 ณSU2 - Concorrente           ณ
 ณSA2 - Fornecedores          ณ
 ณAC4 - Parceiros             ณ
 ณSUS - Prospect              ณ
 ณACH - Suspect               ณ
 ณSA4 - Transportadora        ณ
 ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
*/

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAdiciona os campos do cargo do contato no aHeaderณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cCposEsp	:= "U5_FUNCAO/U5_DFUNCAO"
cCposNao	:= "U5_STATUS/U5_TIPO/U5_ATIVO"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAlimenta o array com as entidades que serao exibidas para o usuarioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
AEval( aEntidades, { |x| AAdd( aOpcoes, x[2] ) } )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCarrega o aHeader do contatoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
SX3->(DbSetOrder(1))
SX3->(DbSeek("SU5"))
While SX3->(! Eof()) .AND. (SX3->X3_ARQUIVO == "SU5")
	//Apenas os campos contidos no folder 1 (Cadastrais)	
	If ((SX3->X3_FOLDER  == "1") .OR. (AllTrim(SX3->X3_CAMPO) $ cCposEsp )) .AND. X3Uso(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL .AND. !(AllTrim(SX3->X3_CAMPO) $ cCposNao)
		cAux	:= AllTrim(X3Titulo())
		Aadd(aHeader, {cAux,;
		               SX3->X3_CAMPO,;
		               SX3->X3_PICTURE,;
		               SX3->X3_TAMANHO,;
		               SX3->X3_DECIMAL,;
		               SX3->X3_VALID,;
		               SX3->X3_USADO,;
		               SX3->X3_TIPO,;
		               SX3->X3_F3,;
		               SX3->X3_CONTEXT } )
		If X3Obrigat(SX3->X3_CAMPO)
			AAdd(aObrigat,{AllTrim(SX3->X3_CAMPO),cAux})
		EndIf
		nUsado++
	Endif
	SX3->(DbSkip())
EndDo
SX3->(DbSetOrder(2))
If SX3->(DbSeek("U5_AUTORIZ")) // Campo de referencia
	Aadd(aHeader, {"Novo",;
	               "REFCONT",;
	               "",;	//X3_PICTURE
	               1,;	//X3_TAMANHO
	               0,;	//X3_DECIMAL
	               "",;	//X3_VALID
	               SX3->X3_USADO,;
	               "L",;  // X3_TIPO
	               "",;   // X3_F3
	               "V"} ) // X3_CONTEXT
EndIf

AdHeadRec("SU5", aHeader)
nUsado += 2

nPRefCont := Ascan(aHeader,{|x| Alltrim(x[2]) == "REFCONT"})

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInicializa o ACOLS do Contato ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Aadd(aColsCont,Array(nUsado+1))
For nI := 1 TO nUsado
	If IsHeadRec(aHeader[nI][2])
		aColsCont[Len(aColsCont)][nI] := 0
	ElseIf IsHeadAlias(aHeader[nI][2])
		aColsCont[Len(aColsCont)][nI] := "SU5"
	ElseIf nI == nPRefCont
		aColsCont[Len(aColsCont)][nI] := .T.
	Else
		aColsCont[Len(aColsCont)][nI] := CriaVar(aHeader[nI][2],.F.)
	EndIf
Next nI
aColsCont[Len(aColsCont)][nUsado+1] := .F.
    
nPContato	:= 	Ascan(aHeader,{|x| Alltrim(x[2]) == "U5_CODCONT"})
        
If !lHelpDesk

	cEntidade	:=	IIf(Empty(M->UC_ENTIDAD),aEntidades[nOpAlias,1],M->UC_ENTIDAD)
	
	nPos 		:= aScan( aTamCpos, {|x| x[1] == cEntidade} )
	nTamA1_COD	:= If( nPos > 0, aTamCpos[nPos, 2], 6 )
	
	cCodigo	:= IIf(Empty(M->UC_CHAVE),Iif(!Empty(cCodigo),cCodigo,Space(nTamA1_COD)),SubStr(M->UC_CHAVE,1,nTamA1_COD))
	cLoja		:= IIf(Empty(M->UC_CHAVE),cLoja,SubStr(M->UC_CHAVE,nTamA1_COD+1,Len(M->UC_CHAVE)-nTamA1_COD))
	nOpAlias	:= Iif(Empty(M->UC_ENTIDAD),nOpAlias,aScan(aEntidades,{|x|x[1] == M->UC_ENTIDAD}))

	If lPls .AND. !Empty(M->UC_CHAVE) .AND. cEntidade == "BA1"
		cCodigo := SubStr(M->UC_CHAVE,1,17)
	EndIf
Else
	If cReadVar == "M->ADE_CODCON"
		cEntidade	:= IIf(Empty(M->ADE_ENTIDA),aEntidades[nOpAlias,1],M->ADE_ENTIDA)
	
		nPos 		:= aScan( aTamCpos, {|x| x[1] == cEntidade} )
		nTamA1_COD	:= If( nPos > 0, aTamCpos[nPos, 2], 6 )

		cCodigo		:= IIf(Empty(M->ADE_CHAVE),cCodigo,SubStr(M->ADE_CHAVE,1,nTamA1_COD))
		cLoja		:= IIf(Empty(M->ADE_CHAVE),cLoja,SubStr(M->ADE_CHAVE,nTamA1_COD+1,Len(M->ADE_CHAVE)-nTamA1_COD))
		nOpAlias	:= Iif(Empty(M->ADE_ENTIDA),nOpAlias,aScan(aEntidades,{|x|x[1] == M->ADE_ENTIDA}))
	ElseIf cReadVar == "M->ADE_CODREP"
		cEntidade	:= IIf(Empty(M->ADE_ENTREP),aEntidades[nOpAlias,1],M->ADE_ENTREP)
	
		nPos 		:= aScan( aTamCpos, {|x| x[1] == cEntidade} )
		nTamA1_COD	:= If( nPos > 0, aTamCpos[nPos, 2], 6 )

		cCodigo	:= IIf(Empty(M->ADE_CHVREP),cCodigo,SubStr(M->ADE_CHVREP,1,nTamA1_COD))
		cLoja		:= IIf(Empty(M->ADE_CHVREP),cLoja,SubStr(M->ADE_CHVREP,nTamA1_COD+1,Len(M->ADE_CHAVE)-nTamA1_COD))
		nOpAlias	:= Iif(Empty(M->ADE_ENTREP),nOpAlias,aScan(aEntidades,{|x|x[1] == M->ADE_ENTREP}))
	EndIf
EndIf
cChave		:=  Alltrim(cCodigo+cLoja)

aAlterSU5 := ValPETkCt(cEntidade,cChave,1,@lInCont,aHeader)

RegToMemory( "SU5", .T. )

aPDFields := {"A1_NOME","A1_NREDUZ","A1_END","A1_BAIRRO","A1_MUN","A1_EST","A1_CEP","A1_TEL",;
				"U5_CONTAT","U5_FONE","U5_CELULAR","U5_FAX","U5_FCOM1","U5_FCOM2","U5_EMAIL","U5_FUNCAO"}
FATPDLoad(Nil, Nil, aPDFields)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ  
//ณMostra os dados do contatoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DEFINE MSDIALOG oDlgEnt FROM  0,0 TO 510,700 TITLE STR0006  PIXEL // "Sele็ใo de Entidades"  


	oFolder := TFolder():New(001,001,{STR0081,STR0082},,oDlgEnt,,,,.T.,.F.,oDlgEnt:nClientWidth/2-3,oDlgEnt:nClientHeight/2) //"Contato"###"Pesquisar"

	@ 001,005 TO 094,100 LABEL STR0007		OF oFolder:aDialogs[1]  PIXEL	// "Entidades"
	@ 001,105 TO 094,345 LABEL STR0063		OF oFolder:aDialogs[1]  PIXEL	// "Informa็๕es da entidade"
	@ 095,005 TO 174,345 LABEL STR0064		OF oFolder:aDialogs[1]  PIXEL	// "Contatos"
	@ 175,005 TO 235,210 LABEL STR0043		OF oFolder:aDialogs[1]  PIXEL	// "Informa็๕es do contato"

	@ 10,110 SAY STR0009 SIZE 50,8 OF oFolder:aDialogs[1] PIXEL //"Entidade"
	@ 10,190 SAY STR0010 SIZE 30,8 OF oFolder:aDialogs[1] PIXEL //"Loja"
	
	If cPaisLoc == "BRA"
		@ 10,240 SAY STR0059 SIZE 52,8 OF oFolder:aDialogs[1] PIXEL // "Localizar CNPJ
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCria os radioboxes pelo constructor para garantir que todos na consulta T5  sejam criados        ณ
	//ณAlem disso, o evento CHANGE de cada radiobox vai atualizar a consulta F3 de acordo com a entidadeณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oEntidade:= TRadMenu():New(10, 10, aOpcoes,;
						  		bSETGET(nOpAlias), oFolder:aDialogs[1] , NIL ,;
						  		{|| nOpAlias := oEntidade:nOption,IIF(aEntidades[nOpAlias,1] == "SA1",oCodigo:cF3 :="CLT",IIF(AllTrim(aEntidades[nOpAlias,1]) == "BA1",oCodigo:cF3 := "BY2PLS",oCodigo:cF3 := aEntidades[nOpAlias,1])),;
						  		nPos := aScan(aTamCpos,{|x| x[1] == AllTrim(aEntidades[nOpAlias,1])}),nTam := If(nPos > 0,aTamCpos[nPos,2],6),cCodigo := Space(nTam),oCodigo:Refresh(),cLoja:=Space(2),oLoja:Refresh(),;
						  		cEntidade:=aEntidades[nOpAlias,1],	cContato := IIF(Len(aColsCont)>=oGetSU5:nAt .AND. Len(aColsCont[oGetSU5:nAt])>=nPContato, aColsCont[oGetSU5:nAt][nPContato], ""),;
						  		cChave:=Alltrim(cCodigo+cLoja),;
						  		TkValEntidade(	1			,cEntidade	,cChave			,aHeader	,;
												@aColsCont		,oGetSU5	,@cCodigo		,@oCodigo	,;
												@cLoja		,@oLoja		,@oNome			,@cNome		,;
												@oFantasia	,@cFantasia	,@oEndereco		,@cEndereco	,;
												@oBairro	,@cBairro	,@oCidade		,@cCidade	,;
												@oEstado	,@cEstado	,@oCep			,@cCep		,;
												@oTelefone	,@cTelefone	,nLenSX8		,@oCntFRes	,;
												@cCntFRes	,@oCntFCel	,@cCntFCel		,@oCntFFax	,;
												@cCntFFax	,@oCntFCom1	,@cCntFCom1		,@oCntFCom2	,;
												@cCntFCom2	,@oCntMail	,@cCntMail		,@oCntCargo	,;
												@cCntCargo	,@lInCont 	,@aColsIni)},;
								NIL, NIL, NIL, .T., NIL,;
								80, 10, NIL, .T., .T.,;
								.T. )

    //Informacoes do cliente
	@ 24,110 SAY STR0024 SIZE 40,10 OF oFolder:aDialogs[1] PIXEL 					// "Razใo Social: "
	@ 34,110 SAY STR0025 SIZE 30,10	OF oFolder:aDialogs[1] PIXEL 			        // "Fantasia: "
	@ 44,110 SAY STR0026 SIZE 30,10 OF oFolder:aDialogs[1] PIXEL 					// "Endere็o: "
	@ 54,110 SAY STR0027 SIZE 30,10	OF oFolder:aDialogs[1] PIXEL 					// "Bairro :"
	@ 54,250 SAY STR0028 SIZE 25,10 OF oFolder:aDialogs[1] PIXEL 					// "Cidade: "
	@ 64,110 SAY STR0029 SIZE 20,10	OF oFolder:aDialogs[1] PIXEL 					// "Cep :"
	@ 64,180 SAY STR0030 SIZE 30,10	OF oFolder:aDialogs[1] PIXEL 					// "Telefone: "		
	
	//Informacoes do contato
	@ 183,010 SAY STR0044	SIZE 40,10 OF oFolder:aDialogs[1] PIXEL	//"Fone Resid.:"
	@ 183,100 SAY STR0045	SIZE 40,10 OF oFolder:aDialogs[1] PIXEL	//"Celular:"
	@ 193,010 SAY STR0046	SIZE 40,10 OF oFolder:aDialogs[1] PIXEL	//"Fax:"
	@ 193,100 SAY STR0047	SIZE 40,10 OF oFolder:aDialogs[1] PIXEL	//"Fone Com.1:"	
	@ 203,010 SAY STR0048	SIZE 40,10 OF oFolder:aDialogs[1] PIXEL	//"Fone Com.2:"	
	@ 213,010 SAY STR0049	SIZE 40,10 OF oFolder:aDialogs[1] PIXEL	//"E-mail:"	
	@ 223,010 SAY STR0050	SIZE 40,10 OF oFolder:aDialogs[1] PIXEL	//"Cargo:"
    
	@ 10,140 MSGET oCodigo VAR cCodigo SIZE 70,8 Picture "@!" OF oFolder:aDialogs[1] F3 IIF(cEntidade == "BA1","BY2PLS",cEntidade) PIXEL ;
			VALID TkValEntidade(	2			,cEntidade	,Alltrim(cCodigo+cLoja)	,aHeader	,;
									@aColsCont		,oGetSU5	,@cCodigo				,@oCodigo	,;
									@cLoja		,@oLoja		,@oNome					,@cNome		,;
									@oFantasia	,@cFantasia	,@oEndereco				,@cEndereco	,;
									@oBairro	,@cBairro	,@oCidade				,@cCidade	,;
									@oEstado	,@cEstado	,@oCep					,@cCep		,;
									@oTelefone	,@cTelefone	,nLenSX8				,@oCntFRes	,;
									@cCntFRes	,@oCntFCel	,@cCntFCel				,@oCntFFax	,;
									@cCntFFax	,@oCntFCom1	,@cCntFCom1				,@oCntFCom2	,;
									@cCntFCom2	,@oCntMail	,@cCntMail				,@oCntCargo	,;
									@cCntCargo	,@lInCont	,@aColsIni)
	
	@ 10,210 MSGET oLoja VAR cLoja SIZE 020,8 OF oFolder:aDialogs[1] PIXEL ;
			VALID TkValEntidade(	3			,cEntidade	,Alltrim(cCodigo+cLoja)	,aHeader	,;
									@aColsCont		,oGetSU5	,@cCodigo				,@oCodigo	,;
									@cLoja		,@oLoja		,@oNome					,@cNome		,;
									@oFantasia	,@cFantasia	,@oEndereco				,@cEndereco	,;
									@oBairro	,@cBairro	,@oCidade				,@cCidade	,;
									@oEstado	,@cEstado	,@oCep					,@cCep		,;
									@oTelefone	,@cTelefone	,nLenSX8				,@oCntFRes	,;
									@cCntFRes	,@oCntFCel	,@cCntFCel				,@oCntFFax	,;
									@cCntFFax	,@oCntFCom1	,@cCntFCom1				,@oCntFCom2	,;
									@cCntFCom2	,@oCntMail	,@cCntMail				,@oCntCargo	,;
									@cCntCargo	,@lInCont	,@aColsIni)
    
	If cPaisLoc == "BRA"
	 	@ 10,280 MSGET oCNPJ VAR cCNPJ SIZE 055,8 Picture '@R 99.999.999/9999-99' OF oFolder:aDialogs[1] PIXEL ;
				VALID ( aEntCNPJ := TBuscaCNPJ(cCNPJ),; 
				IIf (Len(aEntCNPJ) > 0, lSelEnt := TkEntSel(aEntCNPJ	,@cEntidade,@cCodigo,@cLoja,;
															aEntidades)	,;
															lSelEnt := .F. ),; 
				IIf (lSelEnt, TkValEntidade(	3	  		,cEntidade 			,AllTrim(cCodigo+cLoja)	,aHeader	,;
												@aColsCont		,oGetSU5   			,@cCodigo				,@oCodigo	,;
												@cLoja		,@oLoja				,@oNome					,@cNome		,;
												@oFantasia	,@cFantasia			,@oEndereco				,@cEndereco	,;
												@oBairro	,@cBairro  			,@oCidade			 	,@cCidade	,;
												@oEstado	,@cEstado  			,@oCep				 	,@cCep		,;
												@oTelefone	,@cTelefone			,nLenSX8				,@oCntFRes	,;
												@cCntFRes	,@oCntFCel			,@cCntFCel			 	,@oCntFFax	,;
												@cCntFFax	,@oCntFCom1			,@cCntFCom1			  	,@oCntFCom2	,;
												@cCntFCom2	,@oCntMail			,@cCntMail			  	,@oCntCargo	,;
												@cCntCargo  ,@lInCont			,@aColsIni),''),; 
		   		IIf (lSelEnt,;
		   			(nOpAlias := aScan(aEntidades,{|x| x[1] == cEntidade}),;
		   			oEntidade:Refresh(),;
		   			oCodigo:cF3 := cEntidade,;
		   			cCnpj:=Space(nTamA1_CGC),;
		   			oCNPJ:Refresh()),.T.)) // Fecha Valid
	EndIf
	    
	// MsGet com os dados da entidade		  						
	@ 23,150 MSGET oNome 		VAR cNome 		SIZE 180,8 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLUE NO BORDER WHEN .F. 

	If FATPDActive() .And. FTPDUse(.T.)
		oNome:lObfuscate := FATPDIsObfuscate("A1_NOME")
	EndIf

	@ 33,140 MSGET oFantasia 	VAR cFantasia	SIZE 100,8 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLUE NO BORDER WHEN .F. 
	
	If FATPDActive() .And. FTPDUse(.T.)
		oFantasia:lObfuscate := FATPDIsObfuscate("A1_NREDUZ")
	EndIf
	
	@ 43,140 MSGET oEndereco 	VAR cEndereco	SIZE 200,8 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLUE NO BORDER WHEN .F. 
	
	If FATPDActive() .And. FTPDUse(.T.)
		oEndereco:lObfuscate := FATPDIsObfuscate("A1_END")
	EndIf

	@ 53,140 MSGET oBairro 		VAR cBairro	SIZE 150,8 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLUE NO BORDER WHEN .F. 
	
	If FATPDActive() .And. FTPDUse(.T.)
		oBairro:lObfuscate := FATPDIsObfuscate("A1_BAIRRO") 
	EndIf
	
	@ 53,270 MSGET oCidade 		VAR cCidade	SIZE 060,8 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLUE NO BORDER WHEN .F.
	
	If FATPDActive() .And. FTPDUse(.T.)
		oCidade:lObfuscate := FATPDIsObfuscate("A1_MUN")  
	EndIf
	
	@ 53,330 MSGET oEstado 		VAR cEstado 	SIZE 010,8 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLUE NO BORDER WHEN .F.
	
	If FATPDActive() .And. FTPDUse(.T.)
		oEstado:lObfuscate := FATPDIsObfuscate("A1_EST")
	EndIf

	@ 63,140 MSGET oCEP    		VAR cCEP      Picture "@R 99999-999"	SIZE 040,8 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLUE NO BORDER WHEN .F. 
	
	If FATPDActive() .And. FTPDUse(.T.)
		oCEP:lObfuscate := FATPDIsObfuscate("A1_CEP")
	EndIf
	
	@ 63,210 MSGET oTelefone	VAR cTelefone  	Picture "@R 999 9999999999" SIZE 060,8 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLUE NO BORDER WHEN .F.
	
	If FATPDActive() .And. FTPDUse(.T.)
		oTelefone:lObfuscate := FATPDIsObfuscate("A1_TEL")
	EndIf

	//MsGet com os dados do contato selecionado	
	@ 182,040 MSGET oCntFRes	VAR cCntFRes 	Picture "@R 9999-9999"	SIZE 40,8 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLUE NO BORDER WHEN .F. 
	
	If FATPDActive() .And. FTPDUse(.T.)
		oCntFRes:lObfuscate := FATPDIsObfuscate("U5_FONE")
	EndIf

	@ 182,130 MSGET oCntFCel	VAR cCntFCel 	Picture "" 				SIZE 40,8 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLUE NO BORDER WHEN .F.
	
	If FATPDActive() .And. FTPDUse(.T.)
		oCntFCel:lObfuscate := FATPDIsObfuscate("U5_CELULAR")
	EndIf

	@ 192,040 MSGET oCntFFax	VAR cCntFFax 	Picture "@R 9999-9999"	SIZE 40,8 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLUE NO BORDER WHEN .F. 
	
	If FATPDActive() .And. FTPDUse(.T.)
		oCntFFax:lObfuscate := FATPDIsObfuscate("U5_FAX")
	EndIf

	@ 192,130 MSGET oCntFCom1	VAR cCntFCom1	Picture "@R 9999-9999"	SIZE 40,8 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLUE NO BORDER WHEN .F.
	
	If FATPDActive() .And. FTPDUse(.T.)
		oCntFCom1:lObfuscate := FATPDIsObfuscate("U5_FCOM1")
	EndIf
	
	@ 202,040 MSGET oCntFCom2	VAR cCntFCom2	Picture "@R 9999-9999"	SIZE 40,8 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLUE NO BORDER WHEN .F. 
	
	If FATPDActive() .And. FTPDUse(.T.)
		oCntFCom2:lObfuscate := FATPDIsObfuscate("U5_FCOM2")
	EndIf

	@ 212,040 MSGET oCntMail	VAR cCntMail 	SIZE 170,8 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLUE NO BORDER WHEN .F.

	If FATPDActive() .And. FTPDUse(.T.)
		oCntMail:lObfuscate := FATPDIsObfuscate("U5_EMAIL")  
	EndIf

	@ 222,040 MSGET oCntCargo	VAR cCntCargo	SIZE 170,8 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLUE NO BORDER WHEN .F. 
	
	If FATPDActive() .And. FTPDUse(.T.)
		oCntCargo:lObfuscate := FATPDIsObfuscate("U5_FUNCAO")
	EndIf

  
    @ 77,270 BUTTON oBtnInc PROMPT STR0039	SIZE 30,10 PIXEL;	//"Novo"
	    WHEN lAlteraEnt;
    	ACTION (TkEntInc(cEntidade,@cCodigo,@cLoja),;
    	TkValEntidade(	2			,cEntidade	,Alltrim(cCodigo+cLoja)	,aHeader	,;
						@aColsCont		,oGetSU5	,@cCodigo				,@oCodigo	,;
						@cLoja		,@oLoja		,@oNome					,@cNome		,;
						@oFantasia	,@cFantasia	,@oEndereco				,@cEndereco	,;
						@oBairro	,@cBairro	,@oCidade				,@cCidade	,;
						@oEstado	,@cEstado	,@oCep					,@cCep		,;
						@oTelefone	,@cTelefone	,nLenSX8				,@oCntFRes	,;
						@cCntFRes	,@oCntFCel	,@cCntFCel				,@oCntFFax	,;
						@cCntFFax	,@oCntFCom1	,@cCntFCom1				,@oCntFCom2	,;
						@cCntFCom2	,@oCntMail	,@cCntMail				,@oCntCargo	,;
						@cCntCargo	,@lInCont	,@aColsIni));
		OF oFolder:aDialogs[1] Message STR0040 WHEN cEntidade <> 'BA1' //"Inclui um novo registro para a entidade selecionada"
		
    @ 77,310 BUTTON oBtnAlt PROMPT STR0041	SIZE 30,10 PIXEL;	//"Altera"
    	WHEN lAlteraEnt;
    	ACTION (TkEntAlt(cEntidade,cCodigo,cLoja),;
    	TkValEntidade(	2			,cEntidade	,Alltrim(cCodigo+cLoja)	,aHeader	,;
						@aColsCont		,oGetSU5	,@cCodigo				,@oCodigo	,;
						@cLoja		,@oLoja		,@oNome					,@cNome		,;
						@oFantasia	,@cFantasia	,@oEndereco				,@cEndereco	,;
						@oBairro	,@cBairro	,@oCidade				,@cCidade	,;
						@oEstado	,@cEstado	,@oCep					,@cCep		,;
						@oTelefone	,@cTelefone	,nLenSX8				,@oCntFRes	,;
						@cCntFRes	,@oCntFCel	,@cCntFCel				,@oCntFFax	,;
						@cCntFFax	,@oCntFCom1	,@cCntFCom1				,@oCntFCom2	,;
						@cCntFCom2	,@oCntMail	,@cCntMail				,@oCntCargo	,;
						@cCntCargo	,@lInCont	,@aColsIni));
		OF oFolder:aDialogs[1] Message STR0042 //"Alterar informa็๕es da entidade selecionada"    
    
	//GetDados
	oGetSU5 := MsNewGetDados():New(105,10,160,340,IIF(lInCont,3,2),,,,aAlterSU5,,4096,,,,oFolder:aDialogs[1],aHeader,aColsCont)
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSe o cadastro de contatos estiver normatizado, libera temporariamenteณ
	//ณa edi็ใo dos campos normatizados para que a rotina automแtica        ณ
	//ณpossa atualizar as tabelas corretas.                                 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If FindFunction("A70Normatizado") .And. A70Normatizado()	
		If (nPos := aScan( oGetSU5:aHeader, {|x| AllTrim(x[2]) == "U5_END"} )) > 0
			oGetSU5:aInfo[ nPos ][5]	:= ""
		EndIf          
		If (nPos := aScan( oGetSU5:aHeader, {|x| AllTrim(x[2]) == "U5_BAIRRO"} )) > 0
			oGetSU5:aInfo[ nPos ][5] 	:= ""		
		EndIf             
		If (nPos := aScan( oGetSU5:aHeader, {|x| AllTrim(x[2]) == "U5_MUN"} )) > 0
			oGetSU5:aInfo[ nPos ][5]	:= ""	
		EndIf	
		If (nPos := aScan( oGetSU5:aHeader, {|x| AllTrim(x[2]) == "U5_EST"} )) > 0	
			oGetSU5:aInfo[ nPos ][5]	:= ""		
		EndIf
		If (nPos := aScan( oGetSU5:aHeader, {|x| AllTrim(x[2]) == "U5_CEP"} )) > 0 
			oGetSU5:aInfo[ nPos ][5]	:= ""		    
		EndIf
		If (nPos := aScan( oGetSU5:aHeader, {|x| AllTrim(x[2]) == "U5_PAIS"} )) > 0
			oGetSU5:aInfo[ nPos ][5]  	:= ""
		EndIf
		If (nPos := aScan( oGetSU5:aHeader, {|x| AllTrim(x[2]) == "U5_FCOM1"} )) > 0		
			oGetSU5:aInfo[ nPos ][5] 	:= "" 
		EndIf
		If (nPos := aScan( oGetSU5:aHeader, {|x| AllTrim(x[2]) == "U5_FONE"} )) > 0 		
			oGetSU5:aInfo[ nPos ][5] 	:= ""	 
		EndIf
		If (nPos := aScan( oGetSU5:aHeader, {|x| AllTrim(x[2]) == "U5_FAX"} )) > 0 	
			oGetSU5:aInfo[ nPos ][5] 	:= ""	 
		EndIf
		If (nPos := aScan( oGetSU5:aHeader, {|x| AllTrim(x[2]) == "U5_CELULAR"} )) > 0	
			oGetSU5:aInfo[ nPos ][5] 	:= ""		
		EndIf
		oGetSU5:Refresh()
	EndIf
	
	//Ajusta inicializador do campo U5_CODCONT	
	If (nI := aScan(oGetSU5:aHeader,{|x| AllTrim(x[2]) == "U5_CODCONT"})) > 0
		nPCodCont	:= nI
		oGetSU5:aHeader[nI][12]	:= "NewNumCont()"
		oGetSU5:aHeader[nI][6]	:= "Tk070Cod(M->U5_CODCONT)"
		oGetSU5:aHeader[nI][9]	:= "SU5"
	EndIf

	//Ajusta validacao do campo U5_CPF
	If (nI := aScan(oGetSU5:aHeader,{|x| AllTrim(x[2]) == "U5_CPF"})) > 0
		oGetSU5:aHeader[nI][6] := "TkGDConCpf(M->U5_CPF)"
	EndIf
	
    // Localiza็ใo de um contato
	@ 163,010 SAY STR0065	 				SIZE 22,10	OF oFolder:aDialogs[1] PIXEL	// "Procurar"
    @ 162,033 MSGET oSearch    	VAR cSearch	SIZE 50,8	OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLACK
	@ 162,085 BUTTON oBtnInc PROMPT STR0066	SIZE 30,10 OF oFolder:aDialogs[1] PIXEL ACTION MsgRun(STR0067,"", {||If(TkLocaliza( oGetSU5, cSearch, .T. ),oSearch:SetColor(CLR_BLACK,CLR_WHITE),oSearch:SetColor(CLR_WHITE,CLR_HRED))})	// "Localizar" "Localizando..."
	@ 162,117 BUTTON oBtnInc PROMPT STR0068	SIZE 30,10 OF oFolder:aDialogs[1] PIXEL ACTION MsgRun(STR0067,"", {||If(TkLocaliza( oGetSU5, cSearch, .F. ),oSearch:SetColor(CLR_BLACK,CLR_WHITE),oSearch:SetColor(CLR_WHITE,CLR_HRED))})	// "Pr๓ximo" "Localizando..."
	
	oGetSU5:bLinhaOk			:= {||TkGDConLOK(aObrigat,oGetSU5,oGetSU5:nAt)}
	oGetSU5:lDelete			:= .T.
	oGetSU5:bFieldOk			:= {||TkGdConAtu(@oGetSU5)}
	oGetSU5:bDelOk			:= {||TkCanDelU5(@oGetSU5)}
	oGetSU5:bChange 			:= {||	TkRBackGD(@oGetSU5),;
										TkGdAtuVar(	oGetSU5		, @oCntFRes		,@cCntFRes	,@oCntFCel	,;
													@cCntFCel	, @oCntFFax		,@cCntFFax	,@oCntFCom1	,;
													@cCntFCom1	, @oCntFCom2	,@cCntFCom2	,@oCntMail	,;
													@cCntMail	, @oCntCargo	,@cCntCargo	)}

	DEFINE SBUTTON FROM 220,235 TYPE 15	ENABLE OF oFolder:aDialogs[1] ACTION If(Len(aColsCont)>=oGetSU5:nAt,TkAxVisual(aColsCont[oGetSU5:nAt][nPContato]),.F.) When !Empty(cCodigo)																			//VISUALIZAR
	DEFINE SBUTTON FROM 220,275 TYPE 1		ENABLE OF oFolder:aDialogs[1] ACTION (If((TkVldEnt(@oGetSU5, cCodigo, cLoja, cEntidade) .AND. TkGDConLOK(aObrigat,oGetSU5,oGetSU5:nAt)),(nOpcA:=1,nFolder:=oFolder:nOption,oDlgEnt:End()),.F.))//OK
	DEFINE SBUTTON FROM 220,315 TYPE 2 	ENABLE OF oFolder:aDialogs[1] ACTION (nOpcA:=0, oDlgEnt:End()) 					//CANCELA
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSe a tela foi acionada pela segunda vez na rotina, exibe osณ
	//ณdados preenchidos anteriormente                            ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !Empty(cChave)    
		//Atualiza objetos com os dados da entidade
	    TkValEntidade(	2			,cEntidade	,Alltrim(cCodigo+cLoja)	,aHeader	,;
						@aColsCont		,oGetSU5	,@cCodigo				,@oCodigo	,;
						@cLoja		,@oLoja		,@oNome					,@cNome		,;
						@oFantasia	,@cFantasia	,@oEndereco				,@cEndereco	,;
						@oBairro	,@cBairro	,@oCidade				,@cCidade	,;
						@oEstado	,@cEstado	,@oCep					,@cCep		,;
						@oTelefone	,@cTelefone	,nLenSX8				,@oCntFRes	,;
						@cCntFRes	,@oCntFCel	,@cCntFCel				,@oCntFFax	,;
						@cCntFFax	,@oCntFCom1	,@cCntFCom1				,@oCntFCom2	,;
						@cCntFCom2	,@oCntMail	,@cCntMail				,@oCntCargo	,;
						@cCntCargo	,@lInCont	,@aColsIni)
		
		//Posiciona o contato da GetDados 
		If !lHelpDesk
			cContTmp := M->UC_CODCONT
		Else
			If cReadVar == "M->ADE_CODCON"
				cContTmp := M->ADE_CODCON
			ElseIf cReadVar == "M->ADE_CODREP"
				cContTmp := M->ADE_CODREP
			EndIf
		EndIf    
		
		If (nI := aScan(oGetSU5:aCols,{|x|x[nPCodCont] == cContTmp })) > 0
			oGetSU5:nAt				:= nI
			oGetSU5:oBrowse:nAt		:= nI
			oGetSU5:oBrowse:nRowPos	:= 6
			N						:= nI    			
			oGetSU5:GoTo(nI)
		EndIf
		
		oGetSU5:Refresh()
		oGetSU5:oBrowse:SetFocus()
	Else
		oCodigo:SetFocus()
	EndIf
	
	//Pesquisa direta pelo contato (2a. folder)
	@ 001,003 ComboBox oComboTpPesq Var cOpcCombo Items {STR0069,STR0070,STR0071,STR0072} Size 060,010 PIXEL OF oFolder:aDialogs[2] //"Nome"###"E-Mail"###"C๓digo"###"CPF/CNPJ"
	@ 001,065 MSGET cBuscaDireta SIZE oFolder:aDialogs[2]:nClientWidth/2-110,009	OF oFolder:aDialogs[2] PIXEL
	@ 001,oFolder:aDialogs[2]:nClientWidth/2-40 BUTTON oBtBuscar PROMPT STR0065	SIZE 30,10 OF oFolder:aDialogs[2] PIXEL ACTION BuscaContato(cBuscaDireta,oComboTpPesq:nAt,@aContatos,@oListContatos) //"Procurar"

	oListContatos := TWBrowse():New(015,003,oFolder:aDialogs[2]:nClientWidth/2-5,oFolder:aDialogs[2]:nClientHeight/2-45,,{STR0071,STR0069,STR0073,STR0074,STR0075},,oFolder:aDialogs[2],,,,,,,,,,,,.F.,,.T.,,.F.,,,) //"C๓digo"###"Nome"###"Entidade"###"Cod. Entidade"###"Desc. Entidade"
	aContatos := {{"","","","","",""}}
	oListContatos:SetArray(aContatos)
	oListContatos:bLine := {||{	aContatos[oListContatos:nAt][1],;
								aContatos[oListContatos:nAt][2],;
								aContatos[oListContatos:nAt][3],;
								aContatos[oListContatos:nAt][4],;
								aContatos[oListContatos:nAt][5],;
								aContatos[oListContatos:nAt][6]}}
	aPDCols := {"","A1_NOME","","","U5_CONTAT"} 

	If FATPDActive() .And. FTPDUse(.T.)
		oListContatos:aObfuscatedCols := FATPDColObfuscate(aPDCols)
	EndIf

	bConf := {|| Iif(!Empty(aContatos[oListContatos:nAt][1]),;
		(cEntidade := aContatos[oListContatos:nAt][6],;
			 aTamCodLj := TkEntTam( cEntidade ),;
			 cContato := aContatos[oListContatos:nAt][1],;
			 cCodigo := SubStr(aContatos[oListContatos:nAt][4],1,aTamCodLj[1]),;
			 cLoja := SubStr(aContatos[oListContatos:nAt][4],aTamCodLj[1]+1,aTamCodLj[2]),;
			 nOpcA := 1,;
			 nFolder:=oFolder:nOption,;
			 oDlgEnt:End()),;
		 (nOpcA := 0, oDlgEnt:End()) ) }

	oListContatos:bLDblClick := bConf

	DEFINE SBUTTON FROM oFolder:aDialogs[2]:nClientHeight/2-25,005 TYPE 1	ENABLE OF oFolder:aDialogs[2] ACTION Eval(bConf)
	DEFINE SBUTTON FROM oFolder:aDialogs[2]:nClientHeight/2-25,040 TYPE 2	ENABLE OF oFolder:aDialogs[2] ACTION (nOpcA := 0, oDlgEnt:End())
	
	//A pesquisa de contatos nao sera suportada em ambiente Codebase
	#IFNDEF TOP
		oFolder:HidePage(2)
	#ENDIF

	FATPDLogUser("TKSELENT")    
	
ACTIVATE MSDIALOG oDlgEnt CENTER

//Finaliza o gerenciamento dos campos com prote็ใo de dados.
FATPDUnLoad()   

If nOpcA ==1
	
	If nFolder == 1
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณGrava os dados do contato na tabela SU5 e faz a amarracaoณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If !Empty(cCodigo+cLoja) .And. lInCont
			Begin Transaction
				TkInsSU5(cEntidade, AllTrim(cCodigo+cLoja), oGetSU5, aObrigat, nLenSX8, aColsIni)
			End Transaction
		EndIf	
	
		If !Empty(oGetSU5:aCols[oGetSU5:nAt][nPContato])
			cContato := oGetSU5:aCols[oGetSU5:nAt][nPContato]
		Endif
	EndIf
	
	If !lHelpDesk
		If aEntidades[nOpAlias,1] == "SUS"
			lProspect := .T.
		Else
			lProspect := .F.
		Endif		
	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณAtualiza a enchoice do TMK com os dados da entidade selecionada e o rodape do atendimento ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		M->UC_CODCONT	:= cContato
	 	M->UC_DESCNT	:= TkDadosContato(cContato,0)
		TkCliente(cEntidade,Alltrim(cCodigo+cLoja))
	
		M->UC_DESCENT := Posicione("SX2",1,cEntidade,"X2NOME()") 						//Cadastro de ""
		M->UC_DESCIND := ALLTRIM(Posicione("SIX",1,cEntidade+ "1","SIXDescricao()"))   	//Indice:Codigo + Loja
		M->UC_CHAVE   := Alltrim(cCodigo+cLoja)         									//Codigo+Loja 
		M->UC_DESCCHA := TkEntidade(cEntidade,Alltrim(cCodigo+cLoja),1)					//Empresa X Ltda.	
		M->UC_ENTIDAD := cEntidade														//Alias da Entidade
	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณAtualiza os dados da entidade em todos os folders configurados para o operadorณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If cTipoAte $ "45"	//Ambos ou Tmk X Tlv
			If cTipoAte == "4"	//Ambos
				If !lProspect .AND. cEntidade == "SA1"	
					M->ACF_CLIENT		:= cCodigo											//Codigo da Entidade
					M->ACF_LOJA    	:= cLoja    											//Loja da Entidade                                          	
					M->ACF_DESC    	:= TkEntidade(cEntidade,Alltrim(cCodigo+cLoja),1)	//Nome da Entidade
			        M->ACF_CODCON  	:= cContato											//Codigo do Contato
			        M->ACF_DESCNT  	:= TkDadosContato(cContato,0)						//Nome do Contato 
			    Endif 
		    Endif    
			If lProspect .OR. cEntidade == "SA1"	
				M->UA_CLIENTE	:= cCodigo												//Codigo da Entidade
				M->UA_LOJA   	:= cLoja													//Loja da Entidade   
				M->UA_DESCCLI	:= TkEntidade(cEntidade,Alltrim(cCodigo+cLoja),1)		//Nome da Entidade
				M->UA_CODCONT	:= cContato												//Codigo do Contato
				M->UA_DESCNT	:= TkDadosContato(cContato,0)							//Nome do Contato
	
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณEncerra as operacoes fiscais  O parametro FALSE         ณ
				//ณnao faz a inicializacao do refresh do rodape de impostosณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				MaFisEnd(.F.)
		
				DbSelectarea(cEntidade)
				DbSetorder(1)
				If DbSeek(xFilial(cEntidade)+M->UA_CLIENTE+M->UA_LOJA)
	
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณInicializa os dados do cliente na FUNCAO FISCALณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					MaFisIni(M->UA_CLIENTE,;	// 1-Codigo Cliente/Fornecedor
							 M->UA_LOJA,;		// 2-Loja do Cliente/Fornecedor
							 "C",;				// 3-C:Cliente , F:Fornecedor
							 "N",;				// 4-Tipo da NF
							 IIF(!lProspect,SA1->A1_TIPO,SUS->US_TIPO),;// 5-Tipo do Cliente/Fornecedor
							 Nil,;				// 6-Relacao de Impostos que suportados no arquivo
							 Nil,;				// 7-Tipo de complemento
							 Nil,;				// 8-Permite Incluir Impostos no Rodape .T./.F.
							 Nil,;				// 9-Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
							 Nil,;				// 10-Nome da rotina que esta utilizando a funcao
							 Nil,;				// 11-Tipo de documento
							 Nil,;  			// 12-Especie do documento 
						     IIF(lProspect,M->UA_CLIENTE+M->UA_LOJA,""))// 13- Codigo e Loja do Prospect 
		
				Endif	
				
			Endif	
		Endif	
	Else  
		If Procname(1)=="SPESQCLI"
			cReadVar := "M->ADE_CODCON"
		EndIf	                        
		If cReadVar == "M->ADE_CODCON"
			M->ADE_CODCON		:= cContato
			M->ADE_NMCONT		:= TkDadosContato(cContato,0)
			M->ADE_ENTIDAD	:= cEntidade	  									//SA1
			M->ADE_NMENT		:= Posicione("SX2",1,cEntidade,"X2NOME()")       	//Cadastro de Clientes
			M->ADE_DESCIN		:= ALLTRIM(Posicione("SIX",1,cEntidade+ "1","SIXDescricao()"))        //Codigo + Loja
			M->ADE_CHAVE  	:= Alltrim(cCodigo+cLoja)         //00000101
			M->ADE_DESCCH		:= TkEntidade(cEntidade,Alltrim(cCodigo+cLoja),1) 	   //Empresa X Ltda.	
		ElseIf cReadVar == "M->ADE_CODREP"
			M->ADE_CODREP		:= cContato
			M->ADE_DESREP		:= TkDadosContato(cContato,0)
			M->ADE_ENTREP		:= cEntidade	  									//SA1
			M->ADE_DESENT		:= Posicione("SX2",1,cEntidade,"X2NOME()")       	//Cadastro de Clientes
			M->ADE_CHVREP  	:= Alltrim(cCodigo+cLoja)         //00000101
			M->ADE_DCHREP		:= TkEntidade(cEntidade,Alltrim(cCodigo+cLoja),1) 	   //Empresa X Ltda.
		EndIf
	EndIf
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณRestaura a area anterior para depois posicionar no contato pois o mesmo sera utilizado para retornoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	RestArea(aArea)
	
	Dbselectarea("SU5")
	DbsetOrder(1)
	DbSeek(xFilial("SU5")+cContato)
Else
	If cReadVar == "M->ADE_CODCON"
		If ValType(oEnchTk503)<>"U"					
			oEnchTk503:SetFocus()
		EndIf
	EndIf
Endif                     

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณEsvazia pilha de numeros obtidos do SXE/SXF nao confirmadosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
While ( GetSX8Len() > nLenSX8 )
	RollBackSX8()
EndDo

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ- Somente TMK	e somente para as operacoes de INCLUSAO                                                  ณ
//ณVerifica se exite configuracao de TMK do posto de venda do operador, caso exista o acols jแ foi carregado ณ
//ณ pela fun็ใo TKCliente, e para que a fun็ใo RestInter() nใo zere o acols, foi feito o tratamento abaixo   ณ             									 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !lHelpDesk
	cConfTmk := TkPosto(M->UC_OPERADO,"U0_CONFTMK") // Configuracao TMK
	If !Empty(cConfTmk) .AND. Inclui .AND. (!Empty(cEntidade))
		AcolsBkp:= aClone(aCols)
		RestInter()
		aCols:= aClone(AcolsBkp)
		n := Len(aCols) 
	Else
		RestInter()
	EndIf
Else
	RestInter()
EndIf

Return(nOpcA ==1)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTkLocalizaบ Autor ณ Vendas CRM         บ Data ณ  18/05/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Procura um contato na getdados da fun็ใo TkSelEnt()        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTMKXFUNE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function TkLocaliza( oGetDados, cString, lInicio )
	Static nStartLine		// Controle de pr๓xima procura
	Static nStartCol		// Coluna inicial
	Local nCount 	:= 0	// Contador temporแrio
	Local nCount2	:= 0	// Contador temporแrio
	Local lAchou	:= .F.	// Se encontrou a informa็ใo desejada

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณInicializa a variแvel da linha inicial de procura.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If ValType(nStartLine) <> "N"
		nStartLine := 1
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณInicializa a variแvel da coluna inicial de procura.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If ValType(nStartCol) <> "N"
		nStartCol := 1
	EndIf	
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSe ้ para procurar desde o inํcio.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lInicio
		nStartLine	:= 1
		nStartCol	:= 1	
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณProcura em todas as linhas e colunas pelo conte๚do solicitado.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	For nCount := nStartLine To Len(oGetDados:aCols)		
		For nCount2 := nStartCol To Len(oGetDados:aCols[nCount])
			If ValType(oGetDados:aCols[nCount][nCount2]) == "C"
				If Upper(AllTrim(cString)) $ Upper(AllTrim(oGetDados:aCols[nCount][nCount2]))					
					oGetDados:GoTo(nCount)
					oGetDados:oBrowse:nColPos := nCount2
					oGetDados:Refresh()
					nStartLine	:= nCount
					nStartCol	:= nCount2 + 1
					lAchou := .T.
					Exit
				EndIf
			EndIf
		Next

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณSe jแ encontrou um resultado, saia.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If lAchou
			Exit
		Else
			nStartCol := 1
		EndIf		
	Next
Return lAchou

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTkValEntidadeบAutor  ณ Vendas Clientes บ Data ณ  11/19/04   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExibe as informacoes da empresa apos a digitacao do codigo  บฑฑ
ฑฑบ          ณe loja da entidade.                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParam.    ณnOrigem   - Local de origem da chamada, onde:               บฑฑ
ฑฑบ          ณ            1 - Mudan็a de entidade                         บฑฑ
ฑฑบ          ณ            2 - Altera็ใo de c๓digo de entidade             บฑฑ
ฑฑบ          ณ            3 - Altera็ใo de loja de entidade               บฑฑ
ฑฑบ          ณcEntidade - Alias da entidade selecionada                   บฑฑ
ฑฑบ          ณcChave   	- Codigo e loja da entidade                       บฑฑ
ฑฑบ          ณaHeader  	- Aheader SU5                                     บฑฑ
ฑฑบ          ณaCols  	- Acols SU5                                       บฑฑ
ฑฑบ          ณoGetSU5  	- Objeto da NewGetDados.                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CALL CENTER - TELECOBRANCA                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function	TkValEntidade(	nOrigem		,cEntidade	,cChave		,aHeader	,;
								aCols		,oGetSU5	,cCodigo	,oCodigo	,;
								cLoja		,oLoja		,oNome		,cNome		,;
								oFantasia	,cFantasia	,oEndereco	,cEndereco	,;
								oBairro		,cBairro	,oCidade	,cCidade	,;
								oEstado		,cEstado	,oCep		,cCep		,;
								oTelefone	,cTelefone	,nLenSX8	,oCntFRes	,;
								cCntFRes	,oCntFCel	,cCntFCel	,oCntFFax	,;
								cCntFFax	,oCntFCom1	,cCntFCom1	,oCntFCom2	,;
								cCntFCom2	,oCntMail	,cCntMail	,oCntCargo	,;
								cCntCargo	,lInCont	,aColsIni)
Local lRet	:= .T.
Local nOrdEnt	:= IIF(cEntidade == "BA1",GetNewPar("MV_PLORDTM",2),1)
Local aAlterSU5	:= {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณNใo atualiza a loja pois ela estแ sendo alterada pelo usuแrio. ณ
//ณA nใo ser que ele tenha deixado em branco, assim pega o padrใo.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nOrigem <> 3 .OR. Empty( Alltrim( cLoja ) )
	cLoja		:=TkEntidade(cEntidade,cChave,12)
EndIf

cNome		:=TkEntidade(cEntidade,cChave,1,nOrdEnt)
cFantasia	:=TkEntidade(cEntidade,cChave,11,nOrdEnt)
cEndereco	:=TkEntidade(cEntidade,cChave,2,nOrdEnt)
cBairro		:=TkEntidade(cEntidade,cChave,10,nOrdEnt)  
cCidade		:=TkEntidade(cEntidade,cChave,3,nOrdEnt)
cEstado		:=TkEntidade(cEntidade,cChave,4,nOrdEnt)
cCEP   		:=TkEntidade(cEntidade,cChave,5,nOrdEnt)
cTelefone	:=StrZero(Val(TkEntidade(cEntidade,cChave,9,nOrdEnt)),3) + TkEntidade(cEntidade,cChave,6,nOrdEnt)

cChave := cCodigo + cLoja

oLoja:Refresh()
oNome:Refresh()
oFantasia:Refresh()
oEndereco:Refresh()
oBairro:Refresh()
oCidade:Refresh()
oEstado:Refresh()
oCEP:Refresh()
oTelefone:Refresh()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณValida conte๚do do campos.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If (nOrigem == 2 .OR. nOrigem == 3) .AND. !Empty( cCodigo )
	DbSelectArea( cEntidade )
	DbSetOrder( nOrdEnt )
	If DbSeek( xFilial( cEntidade ) + cChave )
		lRet := .T.
	Else
		Alert( STR0034 )	// "Entidade nใo encontrada!"
		lRet := .F.
	EndIf
EndIf

If _lTmkXCTET
	aAlterSU5 := ValPETkCt(cEntidade,cChave,1,@lInCont,aHeader)
	oGetSU5:oBrowse:nOpc		:= IIF(lInCont,3,2)
	If lInCont
   		oGetSU5:lDelete := .T.
   		oGetSU5:lInsert := .T.
   		oGetSU5:lUpdate := .T.
	Else
   		oGetSU5:lDelete := .F.
   		oGetSU5:lInsert := .F.
   		oGetSU5:lUpdate := .F.
	EndIf
	oGetSU5:oBrowse:aAlter	:= aAlterSU5
	oGetSU5:Refresh()	
	oGetSU5:oBrowse:SetFocus()
EndIf

If lRet
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณAlimenta o Acols com os contatos relacionados da entidade selecionadaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	TkAtuAcols(	cEntidade	, cChave		, aHeader		, aCols		,;
				oGetSU5		, nLenSX8		, nOrigem		, @oCntFRes	,;
				@cCntFRes	, @oCntFCel		, @cCntFCel		, @oCntFFax	,;
				@cCntFFax	, @oCntFCom1	, @cCntFCom1	, @oCntFCom2,;
				@cCntFCom2	, @oCntMail		, @cCntMail		, @oCntCargo,;
				@cCntCargo	, @aColsIni )
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณValPETkCt บAutor  ณVendas Clientes     บ Data ณ  21/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInclui os contatos relacionados a entidade no acols.        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณcEntidade - Alias da entidade selecionada                   บฑฑ
ฑฑบ          ณcChave   	- Codigo e loja da entidade                       บฑฑ
ฑฑบParam.    ณnOrigem   - Local de origem da chamada, onde:               บฑฑ
ฑฑบ          ณ            1 - Mudan็a de entidade                         บฑฑ
ฑฑบ          ณ            2 - Altera็ใo de c๓digo de entidade             บฑฑ
ฑฑบ          ณ            3 - Altera็ใo de loja de entidade               บฑฑ
ฑฑบ          ณlInCont	- Autoriza็ใo de altera็ใo/inclusใo               บฑฑ
ฑฑบ          ณaHeader	- Estrutura da tabela SU5.                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CALL CENTER - TELEMARKETING                             CJSบฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ValPETkCt(cEntidade,cChave,nOrigem,lInCont,aHeader)

Local nCont   := 1
Local aRetPE  := {}

aAlterSU5 := {}

For nCont := 1 to Len(aHeader)
	If ( aHeader[nCont][10] <> "V") .And. X3USO(aHeader[nCont,7])
		aAdd(aAlterSU5,aHeader[nCont,2])
	EndIf
Next nCont

If _lTmkXCTET
	aRetPE := Execblock("TMKXCTET",.F.,.F.,{cEntidade,cChave,nOrigem,aAlterSU5})
	If ValType(aRetPE[1]) <> "L" .Or. ValType(aRetPE[2]) <> "A"
		Alert("Retorno do PE incorreto. Serแ mantido o padrao!")
	Else
		lInCont	  := aRetPE[1]
		aAlterSU5  := aRetPE[2]
	EndIf
Else
	lInCont 	 := .T.
EndIf

Return aAlterSU5

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTkAtuAcolsบAutor  ณVendas Clientes     บ Data ณ  11/24/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInclui os contatos relacionados a entidade no acols.        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParam.    ณcEntidade - Alias da entidade selecionada                   บฑฑ
ฑฑบ          ณcChave   	- Codigo e loja da entidade                       บฑฑ
ฑฑบ          ณaHeader  	- Aheader SU5                                     บฑฑ
ฑฑบ          ณaCols  	- Acols SU5                                       บฑฑ
ฑฑบ          ณoGetSU5  	- Objeto da NewGetDados.                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CALL CENTER - TELEMARKETING                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function TkAtuAcols(	cEntidade	, cChave	, aHeader	, aCols		,;
							oGetSU5		, nLenSX8	, nOrigem	, oCntFRes	,;
							cCntFRes	, oCntFCel	, cCntFCel	, oCntFFax	,;
							cCntFFax	, oCntFCom1	, cCntFCom1	, oCntFCom2	,;
							cCntFCom2	, oCntMail	, cCntMail	, oCntCargo	,;
							cCntCargo	, aColsIni)

Local aArea		:= GetArea()
Local nI			:= 0
Local lRet			:= .T.
Local nPCargo		:= aScan(oGetSU5:aHeader,{|x| AllTrim(x[2]) == "U5_FUNCAO"})
Local nPDCargo	:= aScan(oGetSU5:aHeader,{|x| AllTrim(x[2]) == "U5_DFUNCAO"})
Local nPRefCont	:= Ascan(aHeader,{|x| Alltrim(x[2]) == "REFCONT"}) 
Local cQuery		:= "" 
Local cAliTmp		:= ""

#IFDEF TOP  
	Local cFilPE		:= ""
#ENDIF

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณEsvazia pilha de numeros obtidos do SXE/SXF nao confirmadosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If (ValType(nLenSX8)) == "N"
	While ( GetSX8Len() > nLenSX8 )
		RollBackSX8()
	EndDo
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณZera o ACOLS do Contato ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aCols	:= {}

#IFDEF TOP  
If TcSrvType()<>"AS/400"
	
	cAliTmp := "SU5"
	
	If Select("SU5") > 0
		SU5->(DbCloseArea())
	EndIf
	
	cQuery := "SELECT SU5.* ,AC8.R_E_C_N_O_ AS RECAC8 "
	cQuery +=   "FROM " + RetSqlName("SU5") + " SU5 "
	cQuery +=         "INNER JOIN " + RetSqlName("AC8") + " AC8 ON AC8_FILIAL = '" + xFilial("AC8") + "' "
	cQuery +=                                                 "AND AC8_CODCON = U5_CODCONT "
	cQuery +=                                                 "AND AC8_ENTIDA = '" + cEntidade + "' "
	cQuery +=                                                 "AND AC8_FILENT = '" + xFilial(cEntidade) + "' "
	cQuery +=                                                 "AND AC8_CODENT = '" + cChave + "' "
	cQuery +=                                                 "AND AC8.D_E_L_E_T_ = ' ' "
	cQuery +=  "WHERE U5_FILIAL = '" + xFilial("SU5") + "' "
	cQuery +=    "AND U5_ATIVO  = '1' "
	cQuery +=    "AND "
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Ponto de entrada para filtrar os contatos.				  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If _lTkContQry
		cFilPE := ExecBlock("TKCONTQRY",.F.,.F.,{cEntidade})
		If ValType(cFilPE) == "C"
			cQuery	+= cFilPE + " AND "
		EndIf
	EndIf
	cQuery += " SU5.D_E_L_E_T_ = ' ' "
	
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliTmp,.T.,.T.)
	For nI := 1 To Len(aHeader)
		If ( aHeader[nI][8] $ "DN" )
			TcSetField(cAliTmp,aHeader[nI][2],aHeader[nI][8],aHeader[nI][4],aHeader[nI][5])
		EndIf
	Next nI 
	
	While !(cAliTmp)->(Eof())
 		AADD(aCols,Array(Len(aHeader)+1))
		For nI := 1 To Len(aHeader)
			If IsHeadRec(aHeader[nI][2])
				aCols[Len(aCols)][nI] := (cAliTmp)->RECAC8
			ElseIf IsHeadAlias(aHeader[nI][2])
				aCols[Len(aCols)][nI] := "AC8"
			ElseIf ( aHeader[nI][10] <> "V") .AND. (aHeader[nI][08] <> "M")
				aCols[Len(aCols)][nI] := (cAliTmp)->&(aHeader[nI][2])
			ElseIf nPRefCont > 0 .And. aHeader[nI][2] == "REFCONT"
				aCols[Len(aCols)][nI] := .F.
			Else
				aCols[Len(aCols)][nI] := CriaVar(aHeader[nI][2],.T.)
			Endif
		Next nI
		If nPDCargo > 0 .AND. nPCargo > 0
			aCols[Len(aCols)][nPDCargo]			:= Posicione("SUM",1,xFilial("SUM")+aCols[Len(aCols)][nPCargo],"UM_DESC")
		EndIf
		aCols[Len(aCols)][Len(aHeader)+1]	:= .F.
		(cAliTmp)->(DbSkip())
	End

	(cAliTmp)->(DbCloseArea())
	ChkFile("SU5")
	
Else
#ENDIF
	Dbselectarea("SU5")
	DbsetOrder(1)
	Dbselectarea("AC8")
	DbsetOrder(2)
	If Dbseek(xFilial("AC8")+cEntidade+xFilial(cEntidade)+cChave)
		While !Eof() .AND.(AC8_ENTIDA + AC8_FILENT + Alltrim(AC8_CODENT)) == (cEntidade + xFilial(cEntidade) + cChave)
			If SU5->(Dbseek(xFilial("SU5")+AC8->AC8_CODCON))
				AADD(aCols,Array(Len(aHeader)+1))
				
				For nI := 1 To Len(aHeader)
					If IsHeadRec(aHeader[nI][2])
						aCols[Len(aCols)][nI] := AC8->(Recno())
					ElseIf IsHeadAlias(aHeader[nI][2])
						aCols[Len(aCols)][nI] := "AC8"
					ElseIf ( aHeader[nI][10] <> "V") .AND. (aHeader[nI][08] <> "M")
						aCols[Len(aCols)][nI] := FieldGet(FieldPos(aHeader[nI][2]))
					Else
						aCols[Len(aCols)][nI] := CriaVar(aHeader[nI][2],.T.)
					Endif
				Next nI
				If nPDCargo > 0 .AND. nPCargo > 0
					aCols[Len(aCols)][nPDCargo]			:= Posicione("SUM",1,xFilial("SUM")+aCols[Len(aCols)][nPCargo],"UM_DESC")
				EndIf
				aCols[Len(aCols)][Len(aHeader)+1]	:= .F.
			Endif
			AC8->(Dbskip())
		End
	Endif
#IFDEF TOP
EndIf
#ENDIF
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInicializa o ACOLS do Contato caso nao existam contatos relacionados a entidade selecionadaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Len(aCols)== 0
	Aadd(aCols,Array(Len(aHeader)+1))
	For nI := 1 TO Len(aHeader)
		If IsHeadRec(aHeader[nI][2])
			aCols[Len(aCols)][nI] := 0
		ElseIf IsHeadAlias(aHeader[nI][2])
			aCols[Len(aCols)][nI] := "AC8"
		ElseIf nPRefCont > 0 .And. aHeader[nI][2] == "REFCONT"
			aCols[Len(aCols)][nI] := .T.
		Else
			aCols[Len(aCols)][nI] := CriaVar(aHeader[nI][2],.F.)
		EndIf
	Next nI
	aCols[Len(aCols)][Len(aHeader)+1] := .F.
	
	If (nI := aScan(aHeader,{|x| AllTrim(x[2]) == "U5_CODCONT"})) > 0
		aCols[Len(aCols)][nI] := NewNumCont()
	EndIf
	
Endif

oGetSU5:aCols := aClone(aCols)
aColsIni	  := aClone(aCols)
oGetSU5:nAt		:= 1
oGetSU5:oBrowse:Refresh()

TkGdAtuVar(oGetSU5,    @oCntFRes,  @cCntFRes,  @oCntFCel,;
           @cCntFCel,  @oCntFFax,  @cCntFFax,  @oCntFCom1,;
           @cCntFCom1, @oCntFCom2, @cCntFCom2, @oCntMail,;
           @cCntMail,  @oCntCargo, @cCntCargo)

RestArea(aArea)
Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณTkInsAC8    บAutor  ณVendas Clientes     บ Data ณ11/24/04   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณInclui o relacionamento do contato com a entidade           บฑฑ
ฑฑบ          ณselecionada.                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParam.    ณcEntidade - Alias da entidade selecionada                   บฑฑ
ฑฑบ          ณcChave   	- Codigo e loja da entidade                       บฑฑ
ฑฑบ          ณaHeader  	- Aheader SU5                                     บฑฑ
ฑฑบ          ณaCols  	- Acols SU5                                       บฑฑ
ฑฑบ          ณoGetSU5  	- Objeto da NewGetDados.                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CALL CENTER - TELEMARKETING                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function TkInsAC8(cEntidade, cChave, aHeader, aCols, oGetSU5) 
           
Local cFilAC8		:= xFilial("AC8")
Local cFilEntida	:= xFilial(cEntidade)
Local lRet			:= .T.

AC8->(DbSetOrder(1))		// AC8_FILIAL+AC8_CODCON+AC8_ENTIDA+AC8_FILENT+AC8_CODENT
If AC8->(! DbSeek(cFilAC8 + SU5->U5_CODCONT + cEntidade + cFilEntida + cChave))
	DbSelectArea("AC8")
	AC8->(RecLock("AC8",.T.))
	AC8->AC8_FILIAL := cFilAC8
	AC8->AC8_FILENT := cFilEntida
	AC8->AC8_ENTIDA := cEntidade
	AC8->AC8_CODENT := cChave
	AC8->AC8_CODCON := SU5->U5_CODCONT
	AC8->(MsUnLock())
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTkAxVisualบAutor  ณVendas Clientes     บ Data ณ  11/24/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Exibe o cadastro de contatos do contato posicionado no     บฑฑ
ฑฑบ          ณ Acols - Somente para visualizacao.                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParam.    ณcContato - Codigo do contato para pesquisa                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CALL CENTER - TELEMARKETING                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function TkAxVisual(cContato)

Local aArea	:= GetArea()
Local lRet	:= .T.
Local cAuxCadastro := ""				// Armazena o conteudo original de cCadastro
         
If Type("cCadastro") == "U"
	Private cCadastro := ""
EndIf 
cAuxCadastro:= cCadastro 
cCadastro 	:= AllTrim(Posicione("SX2",1,"SU5","X2NOME()")) + " - " + STR0062 // "Visualizar"

Dbselectarea("SU5")
DbsetOrder(1)      
Dbseek(xFilial("SU5")+cContato)
AxVisual("SU5",Recno(),2)

cCadastro := cAuxCadastro

RestArea(aArea)
Return(lRet)                    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัอออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณTkHistEntidadeบAutor  ณVendas Clientes  บ Data ณ  12/02/04  บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯอออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณExibe o historico da entidade acumulado (ALIAS)_CODHIST de  บฑฑ
ฑฑบ          ณtodos os atendimentos.                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CALL CENTER                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function TkHistEntidade()

Local lRet		:= .T.  							// Retorno da funcao
Local aArea		:= GetArea() 						// Guarda a area atual
Local cEntidade := ""                              	// Alias da Entidade
Local cCliente	:= ""                              	// Codigo do cliente
Local cLoja		:= ""                              	// Codigo da Loja
Local cChave	:= ""                              	// Chave - Composicao do Codigo e Loja
Local cTipoAte	:= ""

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณArmazena as informacoes do atendimento.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nFolder == 1 // Telemarketing, Televendas ou Telecobranca
	cTipoAte	:= TkGetTipoAte()
	If (cTipoAte $ "145") // Telemarketing , Ambos ou TMK x TLV
	    cEntidade:= M->UC_ENTIDAD
		cChave   := M->UC_CHAVE

	ElseIf cTipoAte == "2" // Televendas
	    cEntidade:= IIF(lProspect,"SUS","SA1")
		cCliente := M->UA_CLIENTE 
		cLoja	 := M->UA_LOJA

        //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณArmazena os dados da chave primaria para pesquisa   ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	    cChave := Alltrim(cCliente+cLoja)

	ElseIf cTipoAte == "3" // Telecobranca
	    cEntidade:= "SA1"
		cCliente := M->ACF_CLIENT 
		cLoja	 := M->ACF_LOJA

        //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณArmazena os dados da chave primaria para pesquisa   ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cChave   := Alltrim(cCliente+cLoja)

	Endif
	
ElseIf nFolder == 2 // Televendas
	cEntidade:= IIF(lProspect,"SUS","SA1")
	cCliente := M->UA_CLIENTE 
	cLoja	 := M->UA_LOJA

    //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณArmazena os dados da chave primaria para pesquisa   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
    cChave := Alltrim(cCliente+cLoja)

ElseIf nFolder == 3 // Telecobranca
    cEntidade:= "SA1"
	cCliente := M->ACF_CLIENT 
	cLoja	 := M->ACF_LOJA

    //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณArmazena os dados da chave primaria para pesquisa   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cChave   := Alltrim(cCliente+cLoja)
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณExibe a consulta apenas se foi encontrada a entidadeณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !Empty(cEntidade) .AND. !Empty(cChave)
	Processa( {|lEnd| TKHistProc(cEntidade,cChave)}, STR0031) //"Aguarde..."
Else
	Help( "", 1, "TKSEMHIST" ) // "Nใo existe hist๓rico acumulado para a entidade selecionada" "Selecione uma entidade que contenha hist๓rico."
Endif

RestArea(aARea)                                                                         
Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTKHistProcบAutor  ณVendas Clientes     บ Data ณ  01/17/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCarrega o historico em variavel de memoria e exibe em tela. บฑฑ
ฑฑบ          ณPermite cancelar o processo se for necessario.              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CALL CENTER                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function TKHistProc(cEntidade,cChave)

Local cMemoHist := ""              					// Contem a observacao acumulada (MEMO)
Local aArea		:= GetArea() 						// Guarda a area atual
Local lRet		:= .T.								// Retorno da Funcao
	
//Objetos
Local oMonoAs  	:= TFont():New( "Courier New",6,0)	// Fonte para o campo Memo
Local oMemoHist										// Objeto do Memo         
Local oDglHist	              						// Objeto da Dialog

Dbselectarea(cEntidade)
DbsetOrder(1)
If Dbseek(xFilial(cEntidade)+cChave)

	ProcRegua(1)	

	DEFINE MSDIALOG oDglHist FROM 05,10 TO 270,450 TITLE STR0011 PIXEL //"Historico da Entidade"
			
		If cEntidade == "SA1"
			IncProc( STR0032 )
			cMemoHist := MSMM(SA1->A1_CODHIST,60)
        Else
        	IncProc( STR0032 )
        	cMemoHist := MSMM(SUS->US_CODHIST,60)
        Endif
        	
		@03,04 TO 107,218 LABEL STR0011 OF oDglHist PIXEL //"Historico da Entidade"
		@15,08 GET oMemoHist VAR cMemoHist OF oDglHist MEMO SIZE 207,80 PIXEL READONLY NO VSCROLL

		oMemoHist:oFont := oMonoAs
		DEFINE SBUTTON FROM 118,170 TYPE 1 ENABLE ACTION oDglHist:End()

	ACTIVATE MSDIALOG oDglHist CENTER

Endif          
	
RestArea(aARea)                                                                         
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTkListas  บAutor  ณVendas Clientes     บ Data ณ  12/02/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExibe uma consulta com as listas existentes para o operador บฑฑ
ฑฑบ          ณexecutar.                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CALL CENTER                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function TkListas(cOperador)

Local lRet			:= .T.
Local aArea			:= GetArea()
Local dData			:= dDataBase	               				//Data considerada para busca das listas de contato para o operador
Local aListas		:= {}        								//Contem as listas de contato para o operador
Local cPercentual	:= ""										//Percentual executado da lista em formato de string
Local aForma		:= TkSx3Box("U4_FORMA")						//Busca no SX3 as opcoes para o campo - Tipo de Lista Ex: Voz, Fax, Cross Posting, Mala Direta, Pendencia
Local aHeadSU6		:= {}										//aHeader do SU6 na NewGetDados 
Local aColsSU6		:= {}	                        			//aCols do SU6 na NewGetDados
Local aSavHeader	:= {}										//Backup do aHeader atual
Local aSavCols		:= {}										//Backup do aCols atual
Local nI			:= 0                                       	//Contador
Local lIncluiAnt	:= INCLUI				                  	//Salva a variavel para execucao da consulta que nao devera estar em uma rotina de inclusao

//Objetos
Local oMarketing := LoadBitmap( GetResources(), "BR_VERDE" )  	//Objetos para a legenda
Local oVendas	 := LoadBitmap( GetResources(), "BR_AZUL" )		//Objetos para a legenda
Local oCobranca  := LoadBitmap( GetResources(), "BR_VERMELHO" )//Objetos para a legenda
Local oDlgListas
Local oBmp1														//Objetos para a legenda
Local oBmp2														//Objetos para a legenda
Local oBmp3														//Objetos para a legenda
Local oGetSU6                                                   //NewGetDados com os itens da lista

DEFAULT	cOperador	:= TkOperador()	

INCLUI:=.F.

//ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCarrega as listas de contato existentes para o operador ate a data atual e ordena por dataณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aListas:=Tk380CarregaSU4(dData)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณQuando nao existem listas a serem executadas para o operador, o array aListas contemณ
//ณuma linha com o texto "Nao ha atividades para esta data"                            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Len(aListas) == 0 
	lRet:= .F.
Else
	If Empty(aListas[1][1])//Posicao correspondente ao codigo da lista
		lRet:=.F.
	Endif	
Endif	         

If !lRet
	Help( "", 1, "TKSEMLISTA" ) // "Nใo existem listas para o operador at้ a data atual"
	Return(lRet)     
Endif

ASort(aListas,,,{|x,y| DTOS(x[3])+ x[4] < DTOS(y[3])+y[4]})

/*
  ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
  ณEstrutura do array de aAtividades  ณ
  ณ                                   ณ
  ณFuncao Tmka380c/Tk380CarregaSU4    ณ
  ณ                                   ณ
  ณ1- Codigo da Lista de contato.     ณ
  ณ2- Status da Lista de Contatos     ณ
  ณ3- Data da Lista                   ณ
  ณ4- Hora  para execucao da Lista.   ณ
  ณ5- Nome da Lista.                  ณ
  ณ6- Operador que trabalhara a lista.ณ
  ณ7- Rotina.                         ณ
  ณ8- Codigo da ligacao pendente.     ณ
  |9- Forma 						  |
  ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
*/

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSalva e zera o aCols e aHeaderณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aSavHeader	:= aClone( aHeader )
aSavCols	:= aClone( aCols )
aHeader		:= {}
aCols		:= {}                                                                   

FillGetDados(	2				,"SU6"			,1				,/*cSeek*/			,;
				/*{||&cWhile}*/	,{|| .T. }		,/*aNoFields*/	,/*aYesFields*/		,; 
				/*lOnlyYes*/	,/*cQuery*/		,/*bMontCols*/	,.T.				,;
				/*aHeaderAux*/	,/*aColsAux*/	,/*bAfterCols*/	,/*bBeforeCols*/	,;
				/*bAfterHeader*/,/*cAliasQry*/	,{| cField | CriaVar(cField,.F.) } )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRestaura aCols e aHeader e configura aHeadSu6 e aColsSU6ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aHeadSU6	:= aClone( aHeader )
aColsSU6	:= aClone( aCols )
aHeader		:= aClone( aSavHeader )
aCols		:= aClone( aSavCols )

DEFINE MSDIALOG oDlgListas Title STR0014 FROM 0,0 TO 450,600 PIXEL //"Consulta Listas de Contato"
	
	@ 010,005 LISTBOX oLbx FIELDS Header " ",;//Rotina
			 STR0015,;	// "Lista"
			 STR0016,;	// "Descri็ใo"
			 STR0017,;	// "Data"
			 STR0018,;	// "Hora"
			 STR0019,;	// "Forma"
			 STR0020;	// "Percentual ja executado"
			 SIZE 290,090 OF oDlgListas PIXEL
			
	oLbx:SetArray(aListas)
	oLbx:bLine := {||{	IIF(aListas[oLbx:nAt][7] == "3",oCobranca,IIF(aListas[oLbx:nAt][7] == "2",oVendas,oMarketing)),;
							aListas[oLbx:nAt][1],;
							aListas[oLbx:nAt][5],;
							aListas[oLbx:nAt][3],;
							aListas[oLbx:nAt][4],;
							IIF(!Empty(aListas[oLbx:nAt][9]),aForma[Val(aListas[oLbx:nAt][9])],""),;
							cPercentual:=TkListasPerc(aListas[oLbx:nAt][1]);
					}}
	//Carrega os itens da lista de contatos	
	oLbx:bChange := {||	TkListasSU6(aListas[oLbx:nAt][1],@aHeadSU6,@aColsSU6,@oGetSU6)}
	oLbx:Refresh()
	oLbx:SetFocus(.T.)
                                                                                     
	//GetDados
	oGetSU6 := MsNewGetDados():New(110,05,200,295,0,,,,,,4096,,,,oDlgListas,aHeadSU6,aColsSU6)

    // Legendas da Tela
	@ 210,05 BITMAP oBmp1 ResName "BR_VERDE" OF oDlgListas Size 10,10 NoBorder When .F. Pixel
	@ 210,15 SAY STR0021 OF oDlgListas Color CLR_BLUE,CLR_WHITE PIXEL  	//"Marketing" 
	
	@ 210,65 BITMAP oBmp2 ResName "BR_AZUL" OF oDlgListas Size 10,10 NoBorder When .F. Pixel 
	@ 210,75 SAY STR0022  OF oDlgListas Color CLR_BLUE,CLR_WHITE PIXEL  //"Vendas"
	
	@ 210,125 BITMAP oBmp3 ResName "BR_VERMELHO" OF oDlgListas Size 10,10 NoBorder When .F. Pixel 
	@ 210,135 SAY STR0023  OF oDlgListas Color CLR_RED,CLR_WHITE PIXEL  //"Cobran็a"
	
	DEFINE SBUTTON FROM 210,250 TYPE 1	ENABLE OF oDlgListas ACTION (oDlgListas:End())	//OK

	FATPDLogUser('TKLISTAS')	// Log de Acesso LGPD	
ACTIVATE MSDIALOG oDlgListas CENTERED

INCLUI:=lIncluiAnt
RestArea(aARea)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma  ณTkListasPerc บAutor  ณVendas Clientes     บ Data ณ 12/02/04 บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDesc.     ณEfetua o calculo do percentual executado para cada lista    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CALL CENTER                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function TkListasPerc(cLista)

Local nExecutado := 0 			// Variavel para armazenar o valor dos itens executados na lista.
Local nPendente  := 0 			// Variavel para armazenar o valor dos itens pendentes na lista.
Local nTotal     := 0  			// Variavel para armazenar o valor Total dos itens da lista.
Local cPercentual:= ""			// Variavel para armazenar o percentual em forma de string, utilizada para retorno

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณEfetua calculo de percentual executado da lista.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("SU6")
DbSetOrder(1)
If DbSeek(xFilial("SU6")+cLista)
	//(executado*100) / total = Percentual executado
	While !Eof() .AND. (xFilial("SU6") == SU6->U6_FILIAL) .AND. (cLista == SU6->U6_LISTA)
		If SU6->U6_STATUS == '3'
			nExecutado++
		Else
			nPendente++
		EndIf
	
		DbSkip()
	End
	nTotal:= nExecutado+nPendente
	cPercentual := Transform(((nExecutado*100) / nTotal),"999")+"%" // Percentual executado da lista.
Endif

Return(cPercentual)   


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณTkListasSU6บAutor  ณVendas Clientes     บ Data ณ  12/06/04  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณCarrega os itens da lista de contatos                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CALL CENTER                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function TkListasSU6(cLista,aHeadSU6,aColsSU6,oGetSU6)

Local aArea		:= GetArea()	// Salva a area atual
Local nCntFor 	:= 0			// Contador auxiliar
Local cArqQry   := ""			// Alias auxiliar para a Query
Local lQuery    := .F.			// Flag que indica o uso de Query
Local nRecAtu   := 0			// Contador do registro atual
Local nLenAux	:= 0 			// Contador para o FOR
Local aSavHeader:= {}			// Backup do aHeader atual
Local aSavCols	:= {}			// Backup do aCols atual
Local cQuery    := ""			// Composicao do SELECT para a query
Local cSeek		:= ""			// Seek para montagem do aCols
Local cWhile	:= ""			// While para montagem do aCols


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSalva o aHeader e o aCols atual.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aSavHeader	:= aClone( aHeader )
aSavCols	:= aClone( aCols )

If DbSeek(xFilial("SU6") + cLista)


	cSeek := xFilial("SU6")+cLista
	cWhile:= "SU6->U6_FILIAL+SU6->U6_LISTA"
	cQuery:= Nil
	
	#IFDEF TOP
		cQuery 	:= "SELECT * "
		cQuery 	+= "FROM "+RetSqlName("SU6")+" SU6  "
		cQuery 	+= "WHERE SU6.U6_FILIAL='"+xFilial("SU6")+"' AND "
		cQuery 	+= "	SU6.U6_LISTA='"+cLista+"' AND "
		cQuery 	+= "	SU6.D_E_L_E_T_ = ' ' "
		cQuery	+= "ORDER BY "+SqlOrder(SU6->(IndexKey()))
		cQuery	:= ChangeQuery(cQuery)
	
		cSeek := Nil
		cWhile:= Nil
	#ENDIF

	aHeader	:= {}
	aCols	:= {}
	
	FillGetDados(	2				,"SU6"			,1									,cSeek			,;
			 		{|| &cWhile }	,{|| .T. }		,/*aNoFields*/						,/*aYesFields*/	,; 
			 		/*lOnlyYes*/	,cQuery			,/*bMontCols*/						,/*lEmpty*/		,;
			 		/*aHeaderAux*/	,/*aColsAux*/	,/*bAfterCols*/						,/*bBeforeCols*/,;
					/*bAfterHeader*/,/*cAliasQry*/	,{| cField | CriaVar(cField,.T.) }	)
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRestaura aCols e aHeader salvos e configura aHeadSU6 eณ
//ณaColsSU6.                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aHeadSU6:= aClone( aHeader )
aColsSU6:= aClone( aCols )
aHeader	:= aClone( aSavHeader )
aCols	:= aClone( aSavCols )

RestArea(aArea)
oGetSU6:aCols := aClone(aColsSU6)
oGetSU6:oBrowse:Refresh()

Return(.T.)            


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTmkConout บAutor  ณVendas Clientes     บ Data ณ  27/10/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExecuta um conout de acordo com a string passada como       บฑฑ
ฑฑบ          ณparametro para a funcao. Se nenhuma string for passada      บฑฑ
ฑฑบ          ณassume uma padrao.                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณCALL CENTER                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function TmkConout(cTexto,cRotina)

Local lRet	:= .T.
DEFAULT cTexto	:= STR0033
DEFAULT cRotina	:= FUNNAME()

Conout(cRotina + " - " +  Time() + " - " + cTexto)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTkRBackGD บAutor  ณVendas Clientes     บ Data ณ  29/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDescarta os numeros nao utilizados da tabela SXE/SXF, quandoบฑฑ
ฑฑบ          ณo operador muda de linha sem preencher o contato.           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParam.    ณoGetSU5  - Objeto da GetDados de contatos                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณCALL CENTER                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function TkRBackGD(oGetSU5)

Static _nLastLine	:= 0		// Armazena a ultima linha onde esta posicionada a GetDados

If ValType(oGetSU5) == "O"

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSe a linha foi removida (por nao ser preenchida), faz rollbackณ
	//ณda numeracao                                                  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If oGetSU5:lNewLine .AND. (_nLastLine > oGetSU5:oBrowse:nAt)
		RollBackSX8()
	EndIf
	
	_nLastLine	:= oGetSU5:oBrowse:nAt
	
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTkGDConLOKบAutor  ณVendas Clientes     บ Data ณ  30/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValidacao da linha da getdados de contatos, da tela TkSelEntบฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParam.    ณaObrigat - Lista de campos obrigatorios para preenchimento  บฑฑ
ฑฑบ          ณoGetSU5  - Objeto da GetDados de contatos                   บฑฑ
ฑฑบ          ณnLin     - Linha atual da GetDados                          บฑฑ
ฑฑบ          ณlHelp    - Indica se a mensagem pode ou nao ser exibida     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณCall Center                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function TkGDConLOK(aObrigat,oGetSU5,nLin,lHelp)

Local lRet 		:= .T.				// Retorno da validacao da linha
Local nX		:= 1				// Auxiliar de loop
Local nPos		:= 0				// Auxiliar de buscas em vetores
Local nPCont	:= 0				// Auxiliar de buscas em vetores
Local aContato	:= {} 				// Lista dos contatos incluidos no aCols

DEFAULT nLin	:= N				// Linha atual do aCols
DEFAULT lHelp	:= .T.				// Indica se exibe a mensagem de erro ou nao

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณValida os campos obrigatoriosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
While lRet .AND. (nX <= Len(aObrigat))
	nPos := aScan( oGetSU5:aHeader, {|x| AllTrim(x[2]) == aObrigat[nX][1] })
	If (nPos > 0) .AND. (Empty(oGetSU5:aCols[nLin][nPos]))
		lRet 	:= .F.
		If lHelp
			MsgInfo(STR0035 + aObrigat[nX][2],STR0001)//"Favor preencher o campo "###"Atencao"
		EndIf
	EndIf
	nX++
End

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณValida se algum contato foi inserido mais de uma vez no aColsณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lRet
	nPCont	:= aScan(oGetSU5:aHeader,{|x|AllTrim(x[2])== "U5_CODCONT"})
	For nX := 1 to Len(oGetSU5:aCols)
		If !aTail(oGetSU5:aCols[nX])
			If aScan(aContato,oGetSU5:aCols[nX][nPCont]) == 0
				AAdd(aContato,oGetSU5:aCols[nX][nPCont])
			Else
				If lHelp
					MsgInfo(STR0036 + oGetSU5:aCols[nX][nPCont], STR0001)//"Contato duplicado: "###"Atencao"
				EndIf
				lRet := .F.
				Exit
			EndIf
		EndIf
	Next nX
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณTkInsSU5   บAutor  ณVendas Clientes     บ Data ณ  30/11/07  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณFaz o relacionamento do contato com a entidade utilizada    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParam.    ณcEtidade - Alias da entidade selecionada pelo usuario       บฑฑ
ฑฑบ          ณcChave   - Codigo+Loja da entidade                          บฑฑ
ฑฑบ          ณoGetSU5  - Objeto da GetDados de contatos                   บฑฑ
ฑฑบ          ณaObrigat - Lista de campos obrigatorios para preenchimento  บฑฑ
ฑฑบ          ณnLenSX8  - Quantidade de codigos reservados no SXE/SXF      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณCall Center                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function TkInsSU5(cEntidade, cChave, oGetSU5, aObrigat, nLenSX8, aColsIni)

Local aArea		:= GetArea()		// Armazena o posicionamento atual
Local nX			:= 0				// Auxiliar de loop
Local nY			:= 0				// Auxiliar de loop
Local nOpc			:= 0				// Opcao de cadastro
Local nPosCod		:= 0				// Auxiliar de busca
Local lIncluiBk	:= INCLUI			// Armazena o conteudo da variavel INCLUI
Local lAlteraBk	:= ALTERA			// Armazena o conteudo da variavel ALTERA
Local aContAlt	:= {}				// Armazena a posi็ใo dos contatos alterados e incluํdos
Local nReg			:= 0
Local nPosRefC	:= 0
Local cFilSU5		:= xFilial("SU5")

Private lMsErroAuto	:= .F.				// Indica a presenca de erro na execucao da msexecauto
             
If !(fCompArray(oGetSU5:aCols,aColsIni))	//Verifica se houve alguma altera็ใo nos contatos

	nPosRefC := aScan(oGetSU5:aHeader,{|x|Alltrim(x[2])=="REFCONT"})

	For nX := 1 to Len(oGetSU5:aCols)
		// Guarda a posi็ใo dos contatos que foram incluํdos ou que tiveram altera็ใo.
		If (nX <= Len(aColsIni) .And. (!fCompArray(oGetSU5:aCols[nX],aColsIni[nX]))) .Or.;
			((nPosRefC > 0 .And. oGetSU5:aCols[nX,nPosRefC]) .Or. nX > Len(aColsIni))
			AAdd(aContAlt, nX)
		EndIf
	Next nX

	For nX := 1 to Len(aContAlt)
		aContato	:= {}
		nReg		:= aContAlt[nX]
		// Verifica se o contato pode ser incluido ou alterado, validando as linhas deletadas e preenchimentos corretos
		If !(aTail(oGetSU5:aCols[nReg])) .AND. TkGDConLOK(aObrigat,oGetSU5,nReg,.F.)
			// Prepara array da rotina automatica
			AAdd(aContato,{"U5_FILIAL", cFilSU5, Nil})
			For nY := 1 To Len(oGetSU5:aHeader)
				If !Empty(oGetSU5:aCols[nReg,nY])
					AAdd(aContato,{oGetSU5:aHeader[nY,2],oGetSU5:aCols[nReg,nY],Nil})
				EndIf
			Next nY
		ElseIf aTail(oGetSU5:aCols[nReg])
			// Se a linha foi deletada, remove o relacionamento entre contato e entidade (AC8)
			AC8->(DbSetOrder(1))	//AC8_FILIAL+AC8_CODCON+AC8_ENTIDA+AC8_FILENT+AC8_CODENT
			If AC8->(DbSeek(xFilial("AC8")+oGetSU5:aCols[nReg][aScan(oGetSU5:aHeader,{|x|AllTrim(x[2])=="U5_CODCONT"})]+cEntidade+xFilial(cEntidade)+cChave))
				AC8->(RecLock("AC8",.F.))
				AC8->(DbDelete())
				AC8->(MsUnLock())
			EndIf
		EndIf

		If (Len(aContato) > 0)
			DbSelectArea("SU5")
			DbSetOrder(1)
			nPosCod	:= aScan(aContato, {|x|AllTrim(x[1]) == "U5_CODCONT"})
			nPosRefC	:= aScan(aContato, {|x|Alltrim(x[1]) == "REFCONT"})
			// Se o numero do contato cadastrado ja estiver relacionado com alguma outra entidade entendesse que se trata de uma nova inclusใo
			If nPosRefC > 0 .And. aContato[nPosRefC][2]
				cMay	:= Alltrim(cFilSU5)+aContato[nPosCod][2]
				FreeUsedCode()
				// Se dois orcamentos iniciam ao mesmo tempo a MayIUseCode impede que ambos utilizem o mesmo numero.
				While SU5->(DbSeek(cFilSU5+aContato[nPosCod][2])) .OR. !MayIUseCode(cMay)
					aContato[nPosCod][2]	:= NewNumCont()
					FreeUsedCode()
					cMay					:= Alltrim(cFilSU5)+aContato[nPosCod][2]
				End
				M->U5_CODCONT																			:= aContato[nPosCod][2]
				oGetSU5:aCols[nReg][aScan(oGetSU5:aHeader,{|x|AllTrim(x[2])=="U5_CODCONT"})]	:= aContato[nPosCod][2]
			EndIf

			// Verifica se trata-se de uma inclusao ou alteracao e executa a MsExecAuto
			If SU5->(DbSeek(cFilSU5+aContato[nPosCod][2]))
				nOpc 	:= 4
				ALTERA	:= .T.
				INCLUI	:= .F.
			Else
				nOpc 	:= 3
				ALTERA	:= .F.
				INCLUI	:= .T.
			EndIf

			// Executa a rotina de inclusao/alteracao e verifica se a transacao ocorreu normalmente
			If FindFunction("A70Normatizado") .And. A70Normatizado()
				SU5->(MSExecAuto({|x,y,z| TMKA070(x,y,,,z)}, aContato, nOpc, .T.))	// O ๚ltimo parโmetro informa a rotina automแtica que mesmo normatizado, que se de a prefer๊ncia ao valores informados no cabe็alho do SU5.
			Else
				SU5->(MSExecAuto({|x,y| TMKA070(x,y)}, aContato, nOpc))
			EndIf

			If lMsErroAuto
				DisarmTransaction()
				MsgStop(STR0037+ " " + aContato[nPosCod][2],STR0001)//"Erro na grava็ใo do contato"###"Atencao"
				MostraErro()
				RollBackSx8()
			Else
				If INCLUI .AND. __lSX8
					ConfirmSx8()
				EndIf
			EndIf

			If !lMsErroAuto
				AC8->(TkInsAC8(cEntidade, cChave, @oGetSU5:aHeader, @oGetSU5:aCols, @oGetSU5))	// Cria relacionamento entre entidade e contato
			EndIf

		EndIf
	Next nX
EndIf

If !lMsErroAuto
	While ( GetSX8Len() > nLenSX8 )
		ConfirmSx8()	// Efetiva a reserva de numeros do SXE/SXF
	EndDo
EndIf

INCLUI	:= lIncluiBk
ALTERA	:= lAlteraBk
RestArea(aArea)
Return Nil

       
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNewNumContบAutor  ณVendas / CRM        บ Data ณ  10/19/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function NewNumCont()
Local cNewNumCont	:= GetSXENum('SU5','U5_CODCONT')
Local nStack		:= GetSX8Len()
Local cFilSU5		:= xFilial("SU5") 
Local lContinua	:= .T.

While lContinua
	lContinua	:= SU5->(DbSeek(cFilSU5 + cNewNumCont))
	If lContinua
		While GetSX8Len() > nStack 
			ConfirmSX8()
		EndDo
		cNewNumCont := GetSXENum('SU5','U5_CODCONT')
	EndIf
EndDo
Return cNewNumCont

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTkGDConCpfบAutor  ณVendas Clientes     บ Data ณ  30/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida o CPF informado pelo operador, para o contato        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParam.    ณcCpf     - Codigo do CPF para validacao                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณCALL CENTER                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function TkGDConCpf(cCpf)

Local aArea	:= GetArea()			//Salva posicionamento atual
Local lRet	:= .T.					//Retorno da funcao

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณValida o cpf informadoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
lRet	:= Empty(cCpf) .OR. ( CGC(M->U5_CPF) .AND. FreeForUse("SU5",M->U5_CPF) )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se algum outro contato tem o mesmo CPFณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lRet
	DbSelectArea("SU5")
	DbSetOrder(8)//U5_FILIAL+U5_CPF
	If DbSeek(xFilial("SU5")+cCpf)
		If SU5->U5_CODCONT <> M->U5_CODCONT
			HELP(" ",1,"JAGRAVADO")
			lRet := .F.
		EndIf			
	EndIf
EndIf

RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTkGdAtuVarบAutor  ณVendas Clientes     บ Data ณ  30/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza as variaveis de memoria a cada troca de linha na   บฑฑ
ฑฑบ          ณgetdados de contatos                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParam.    ณoGetSU5  - Objeto da GetDados de contatos                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณCall Center                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function TkGdAtuVar(oGetSU5,   oCntFRes,  cCntFRes,  oCntFCel,;
                    cCntFCel,  oCntFFax,  cCntFFax,  oCntFCom1,;
                    cCntFCom1, oCntFCom2, cCntFCom2, oCntMail,;
                    cCntMail,  oCntCargo, cCntCargo)

Local nX			:= 0		// Auxiliar de loop
Local nPRefCont	:= Ascan(oGetSU5:aHeader,{|x| Alltrim(x[2]) == "REFCONT"})

Static _nLastItem	:= 0		// Ultima linha validada na GetDados

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณQuando a linha for alterada, todas as variaveis de memoriaณ
//ณsao atualizadas com os valores presentes no aCols         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If oGetSU5:nAt <> _nLastItem
	For nX := 1 to Len( oGetSU5:aHeader )
		M->&( oGetSU5:aHeader[nX][2] ) := oGetSU5:aCols[oGetSU5:nAt][aScan(oGetSU5:aHeader,{ |x| AllTrim( x[2] ) == AllTrim(oGetSU5:aHeader[nX][2]) })]
		If nPRefCont > 0 .And. nPRefCont == nX .And. (Empty(oGetSU5:aCols[oGetSU5:nAt][aScan(oGetSU5:aHeader,{ |x| AllTrim( x[2] ) == AllTrim("U5_CODCONT")})]) )
			oGetSU5:aCols[oGetSU5:nAt][nPRefCont] := .T.
		EndIf
	Next nX
	_nLastItem	:= oGetSU5:nAt
EndIf
                                                                              
If aScan(oGetSU5:aHeader, { |x| AllTrim( x[2] ) == AllTrim("U5_FONE")}) > 0
	cCntFRes	:= oGetSU5:aCols[oGetSU5:nAt][aScan(oGetSU5:aHeader,{ |x| AllTrim( x[2] ) == AllTrim("U5_FONE")})]
EndIf
If aScan(oGetSU5:aHeader, { |x| AllTrim( x[2] ) == AllTrim("U5_CELULAR")}) > 0
	cCntFCel	:= oGetSU5:aCols[oGetSU5:nAt][aScan(oGetSU5:aHeader,{ |x| AllTrim( x[2] ) == AllTrim("U5_CELULAR")})]
EndIf
If aScan(oGetSU5:aHeader, { |x| AllTrim( x[2] ) == AllTrim("U5_FAX")}) > 0
	cCntFFax	:= oGetSU5:aCols[oGetSU5:nAt][aScan(oGetSU5:aHeader,{ |x| AllTrim( x[2] ) == AllTrim("U5_FAX")})]
EndIf
If aScan(oGetSU5:aHeader, { |x| AllTrim( x[2] ) == AllTrim("U5_FCOM1")}) > 0
	cCntFCom1	:= oGetSU5:aCols[oGetSU5:nAt][aScan(oGetSU5:aHeader,{ |x| AllTrim( x[2] ) == AllTrim("U5_FCOM1")})]
EndIf
If aScan(oGetSU5:aHeader, { |x| AllTrim( x[2] ) == AllTrim("U5_FCOM2")}) > 0
	cCntFCom2	:= oGetSU5:aCols[oGetSU5:nAt][aScan(oGetSU5:aHeader,{ |x| AllTrim( x[2] ) == AllTrim("U5_FCOM2")})]
EndIf
If aScan(oGetSU5:aHeader, { |x| AllTrim( x[2] ) == AllTrim("U5_EMAIL")}) > 0
	cCntMail	:= oGetSU5:aCols[oGetSU5:nAt][aScan(oGetSU5:aHeader,{ |x| AllTrim( x[2] ) == AllTrim("U5_EMAIL")})]
EndIf                                                                        
If aScan(oGetSU5:aHeader, { |x| AllTrim( x[2] ) == AllTrim("U5_FUNCAO")}) > 0
	cCntCargo	:= Posicione("SUM",1,xFilial("SUM")+oGetSU5:aCols[oGetSU5:nAt][aScan(oGetSU5:aHeader,{ |x| AllTrim( x[2] ) == AllTrim("U5_FUNCAO")})],"UM_DESC")
EndIf

oCntFRes:Refresh()
oCntFCel:Refresh()
oCntFFax:Refresh()
oCntFCom1:Refresh()
oCntFCom2:Refresh()
oCntMail:Refresh()
oCntCargo:Refresh()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTkGdConAtuบAutor  ณVendas Clientes     บ Data ณ  03/12/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza a getdados de contatos com o contao informado no   บฑฑ
ฑฑบ          ณcampo U5_CODCONT                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParam.    ณoGetSU5  - Objeto da GetDados de contatos                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณCALL CENTER                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function TkGdConAtu(oGetSU5)

Local aArea	   		:= GetArea()				// Salva o posicionamento atual
Local aAreaSU5 		:= SU5->(GetArea())		// Salva o posicionamento do SU5
Local lRet	   		:= .T.						// Retorno da funcao
Local nPosCod		:= 0						// Posicao do campo U5_CODCONT no aHeader
Local nX	   		:= 0 						// Auxiliar de loop
Local nTamHeader	:= Len(oGetSU5:aHeader)		// Quantidade de campos na getdados

nPosCod :=	aScan(oGetSU5:aHeader,{|x|AllTrim(x[2])=="U5_CODCONT"})
nPRefCont := Ascan(oGetSU5:aHeader,{|x| Alltrim(x[2]) == "REFCONT"}) 
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se esta posicionado na coluna do codigoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If (oGetSU5:oBrowse:nColPos == nPosCod)
	
	DbSelectArea("SU5")
	DbSetOrder(1)
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณLocaliza o contato e recupera as suas informacoesณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If DbSeek(xFilial("SU5")+M->U5_CODCONT)
	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณDescarrega valores do banco no aCols e na memoriaณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		For nX :=1 to nTamHeader
			If nPRefCont > 0 .And. oGetSU5:aHeader[nX][2] == "REFCONT"
				oGetSU5:aCols[oGetSU5:nAt][nX] := .F.
			ElseIf SU5->(FieldPos(oGetSU5:aHeader[nX][2])) > 0
				aCols[oGetSU5:nAt][nX] 			:= SU5->&(oGetSU5:aHeader[nX][2])
				oGetSU5:aCols[oGetSU5:nAt][nX]	:= SU5->&(oGetSU5:aHeader[nX][2])
				M->&(oGetSU5:aHeader[nX][2])	:= SU5->&(oGetSU5:aHeader[nX][2])
			EndIf
			If oGetSU5:aHeader[nX][2] == "U5_DFUNCAO"
				oGetSU5:aCols[oGetSU5:nAt][nX]	:= Posicione("SUM",1,xFilial("SUM")+SU5->U5_FUNCAO,"UM_DESC")
				M->U5_DFUNCAO := oGetSU5:aCols[oGetSU5:nAt][nX]
			EndIf
		Next
	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณMarca a linha como preenchidaณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		oGetSU5:lNewLine := .F.
	Else
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณInicializa o ACOLS do Contato ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		For nX := 1 to nTamHeader
			If nPRefCont > 0 .And. oGetSU5:aHeader[nX][2] == "REFCONT"
				oGetSU5:aCols[oGetSU5:nAt][nX] := .T.
			ElseIf oGetSU5:aHeader[nX][2] <> "U5_CODCONT" .And. SU5->(FieldPos(oGetSU5:aHeader[nX][2])) > 0
				aCols[oGetSU5:nAt][nX] 			:= CriaVar(oGetSU5:aHeader[nX][2],.F.)
				oGetSU5:aCols[oGetSU5:nAt][nX]	:= CriaVar(oGetSU5:aHeader[nX][2],.F.)
				M->&(oGetSU5:aHeader[nX][2])	:= CriaVar(oGetSU5:aHeader[nX][2],.F.)
			EndIf
		Next nI
	EndIf
	
EndIf

oGetSU5:Refresh()

RestArea(aAreaSU5)
RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTkVldEnt  บAutor  ณVendas Clientes     บ Data ณ  03/12/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida a selecao do contato                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParam.    ณoGetSU5  - Objeto da GetDados de contatos                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณCall Center                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function TkVldEnt(oGetSU5, cCodigo, cLoja, cEntidade)

Local lRet		  := .T.	// Retorno da funcao
Local nPosCod	  := 0		// Posicao do campo U5_CONTAT no aHeader

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณExecuta ponto de entrada para valida็ใo de usuแrio da entidade ณ
//ณselecionada                                                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If _lTkEntUsr
	If !Execblock( "TKENTUSR" , .F. , .F. , { cEntidade , cCodigo+cLoja } )
		lRet := .f.
	EndIf
EndIf

If lRet 
	If !Empty(cCodigo)
		nPosCod	:= aScan(oGetSU5:aHeader,{|x|AllTrim(x[2])=="U5_CONTAT"})
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณValida se a linha selecionada e' validaณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If aTail(oGetSU5:aCols[oGetSU5:nAt]) .OR. Empty(oGetSU5:aCols[oGetSU5:nAt][nPosCod])
			lRet := .F.
			MsgInfo(STR0038) //"Selecione um contato vแlido"
		EndIf
	Else
		lRet := .F.
		MsgInfo(STR0038) //"Selecione um contato vแlido"
	EndIf
EndIf	
	

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTkEntInc  บAutor  ณVendas Clientes     บ Data ณ  03/12/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina de inclusao de entidades a partir da tela TkSelEnt   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParam.    ณcEtidade - Alias da entidade selecionada pelo usuario       บฑฑ
ฑฑบ          ณcCodigo  - Codigo da entidade                               บฑฑ
ฑฑบ          ณcLoja    - Loja da entidade                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณCALL CENTER                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function TkEntInc(cEntidade,cCodigo,cLoja)

Local aArea		:= GetArea()			// Armazena posicionamento atual
Local lIncluiBk	:= INCLUI				// Armazena o conteudo da variavel INCLUI
Local lAlteraBk	:= ALTERA				// Armazena o conteudo da variavel INCLUI
Local aCposInd	:= {}     				// Campos que compoem o indice do alias
Local aRotBkp	:= aClone(aRotina)		// Armazena o vetor aRotina para recuperacao posterior
Local cAuxCadastro := ""				// Armazena o conteudo original de cCadastro
         
If Type("cCadastro") == "U"
	Private cCadastro := ""
EndIf 
cAuxCadastro:= cCadastro 
cCadastro 	:= AllTrim(Posicione("SX2",1,cEntidade,"X2NOME()")) + " - " + STR0060 // "Incluir"


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRecria o aRotina, para garantir a execucao correta da funcaoณ
//ณAxInclui                                                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aRotina := {{""	,"AxPesqui",0,1} ,;
			{""	,"AxVisual",0,2} ,;
			{""	,"AxInclui",0,3} ,;
			{""	,"AxAltera",0,4} ,;
			{""	,"AxDeleta",0,5} }

INCLUI	:= .T.
ALTERA	:= .F.

DbSelectArea(cEntidade)
DbSetOrder(1)

aCposInd := StrToKArr(IndexKey(),"+")

Do Case
	Case cEntidade == "SA1"
		aRotAuto := Nil
  		A030Inclui(cEntidade,Nil,3)
	Case cEntidade == "SUS"
		FWExecView( STR0060, 'TMKA260', 3,, { || .T. } ) // "Incluir"
	Case cEntidade == "ACH"      
		FWExecView( STR0060, 'TMKA341', 3,, { || .T. } ) //"Incluir"
	Case cEntidade $ "BA1/BAU"
		MsgInfo(STR0083,STR0001)//"Esta fun็ใo s๓ pode ser executada atrav้s do m๓dulo de plano de sa๚de.","Atencion"
	Otherwise
		AxInclui(cEntidade,Nil,3)                             
EndCase


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPreenche os campos codigo e loja com codigo e loja daณ
//ณentidade incluida                                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !cEntidade $ "BA1/BAU"
	cCodigo	:= Iif(Len(aCposInd)>=2,(cEntidade)->&(aCposInd[2]),"")
	cLoja	:= Iif(Len(aCposInd)>=3,(cEntidade)->&(aCposInd[3]),"")
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRestaura situacao anteriorณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aRotina	:= aClone(aRotBkp)
ALTERA	:= lAlteraBk
INCLUI	:= lIncluiBk

cCadastro := cAuxCadastro

RestArea(aArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTkEntAlt  บAutor  ณVendas Clientes     บ Data ณ  03/12/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina de alteracao de entidades a partir da tela TkSelEnt  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParam.    ณcEtidade - Alias da entidade selecionada pelo usuario       บฑฑ
ฑฑบ          ณcCodigo  - Codigo da entidade                               บฑฑ
ฑฑบ          ณcLoja    - Loja da entidade                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณCALL CENTER                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function TkEntAlt(cEntidade,cCodigo,cLoja)

Local aArea		:= GetArea()			// Armazena posicionamento atual
Local lIncluiBk	:= INCLUI				// Armazena o conteudo da variavel INCLUI
Local lAlteraBk	:= ALTERA				// Armazena o conteudo da variavel INCLUI
Local aRotBkp	:= aClone(aRotina)		// Armazena o vetor aRotina para recuperacao posterior
Local cAuxCadastro := ""				// Armazena o conteudo original de cCadastro
Local lAltOk	:= .T.
         
If Type("cCadastro") == "U"
	Private cCadastro := ""
EndIf 
cAuxCadastro:= cCadastro 
cCadastro 	:= AllTrim(Posicione("SX2",1,cEntidade,"X2NOME()")) + " - " + STR0061 // "Alterar"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRecria o aRotina, para garantir a execucao correta da funcaoณ
//ณAxInclui                                                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aRotina := {{""	,"AxPesqui",0,1} ,;
			{""	,"AxVisual",0,2} ,;
			{""	,"AxInclui",0,3} ,;
			{""	,"AxAltera",0,4} ,;
			{""	,"AxDeleta",0,5} }

INCLUI	:= .F.
ALTERA	:= .T.

DbSelectArea(cEntidade)
DbSetOrder(1)

If DbSeek(xFilial(cEntidade)+cCodigo+cLoja)

	If _lTkEntBTA
		lAltOk := Execblock("TKENTBTA",.F.,.F.,{cEntidade,cCodigo,cLoja})
	EndIf

	Do Case
		Case cEntidade == "SA1" .And. lAltOk
			aRotAuto := Nil
	  		A030Altera(cEntidade,Recno(),4)
		Case cEntidade == "SUS" .And. lAltOk
			FWExecView( STR0061, 'TMKA260', 4,, { || .T. } ) //"Alterar"
		Case cEntidade == "ACH" .And. lAltOk
			FWExecView( STR0061, 'TMKA341', 4,, { || .T. } ) //"Alterar"						
		Case cEntidade $ "BA1/BAU" .And. lAltOk
			MsgInfo(STR0083,STR0001)//"Esta fun็ใo s๓ pode ser executada atrav้s do m๓dulo de plano de sa๚de.","Atencion"
		Otherwise
			If lAltOk
				AxAltera(cEntidade,Recno(),4)
			EndIf
	EndCase
Else
	Do Case
		Case cEntidade $ "BA1/BAU"
			MsgInfo(STR0083,STR0001)//"Esta fun็ใo s๓ pode ser executada atrav้s do m๓dulo de plano de sa๚de.","Atencion"
	EndCase
EndIf
     
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRestaura situacao anteriorณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aRotina	:= aClone(aRotBkp)
ALTERA	:= lAlteraBk
INCLUI	:= lIncluiBk

cCadastro := cAuxCadastro
          
RestArea(aArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTBuscaCNPJบAutor  ณVendas Clientes     บ Data ณ  07/02/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna array com Entidade, Codigo e Loja                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1 - CNPJ a ser pesquisado                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณCall Center                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function TBuscaCNPJ(cCnpj)
 
Local aSavArea := GetArea()
Local aAreaSX5 := SX5->(GetArea())
Local aAreaACH := ACH->(GetArea())
Local aAreaSA1 := SA1->(GetArea())
Local aAreaSA2 := SA2->(GetArea())
Local aAreaSA4 := SA4->(GetArea())
Local aAreaSUS := SUS->(GetArea())
Local aRet     := {}
Local aAlias   := {}
Local i	       := 0
Local cTipoTam	:= GetMV("MV_TMKTPT",,"1") //1-Tamanho do campo CNPJ Fixo,2=Tamanho Variแvel
Local cTipoVld	:= GetMv("MV_TMKCGC",,"1") //1=Valida CNPJ,2=Apenas Raiz do CNPJ
Local nLenCnpj	:= 0 

// Retira caracteres de picture caso existam 
cCnpj := STRTRAN(cCnpj,'.','')
cCnpj := STRTRAN(cCnpj,'/','')
cCnpj := STRTRAN(cCnpj,'-','')
cCnpj := AllTrim(cCnpj)

//Se o Cnpj nao foi informado, aborta a busca
If Empty(cCnpj)
	RestArea(aSavArea)
	Return aRet
EndIf

DbSelectArea("SX5")      
DbSetOrder(1)
If DbSeek(xFilial("SX5")+"T5") 
   While SX5->(!eof()) .and. Alltrim(SX5->X5_TABELA) == "T5"
         aAdd(aAlias,{Alltrim(SX5->X5_CHAVE)})            
         SX5->(DbSkip()) 
   EndDo
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณControla quantos caracteres serao avaliados do CNPJณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If cTipoVld == "1"
	nLenCnpj := 14
Else
	nLenCnpj := 8
EndIf



//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณControla quantos caracteres serao avaliados do CNPJณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If cTipoTam=="1"

	If cTipoVld == "1"
		nLenCnpj := 14
	Else
		nLenCnpj := 8
	EndIf

	cCnpj	:= SubStr(cCnpj,1,nLenCnpj)
	
Else
	nLenCnpj := Len(cCnpj)
	
EndIf

For i := 1 to Len(aAlias) 

     Do Case

        /*
        Tabela AC4 Nao Possui CNPJ na Estrutura
        Tabela SU2 Nao Possui CNPJ na Estrutura
        */

        Case aAlias[i,1] == 'ACH'  // SUSPECTS 
             DbSelectArea('ACH') 
             DbSetOrder(2)
             If DbSeek(xFilial('ACH')+cCnpj)
                Do While ! Eof() .AND. ACH->ACH_FILIAL == xFilial('ACH') .AND. SubStr(ACH->ACH_CGC,1,nLenCNPJ) == ALLTRIM(cCnPj)
                   aAdd(aRet,{'ACH',ACH->ACH_CODIGO,ACH->ACH_LOJA})
                   ACH->(dbSkip())
                Enddo                                                     
             EndIf

        Case aAlias[i,1] == 'SA1'  // CLIENTES
             DbSelectArea('SA1') 
             DbSetOrder(3)
             If DbSeek(xFilial('SA1')+cCnpj) 
                Do While ! Eof() .and. SA1->A1_FILIAL == xFilial('SA1') .AND. SubStr(SA1->A1_CGC,1,nLenCNPJ) == ALLTRIM(cCnPj)
                   aAdd(aRet,{'SA1',SA1->A1_COD,SA1->A1_LOJA})
                   SA1->(dbSkip())
                Enddo   
             EndIf
                                        
        Case aAlias[i,1] == 'SA2'  // FORNECEDORES   
             DbSelectArea('SA2') 
             DbSetOrder(3)
             If DbSeek(xFilial('SA2')+cCnpj) 
                Do While ! Eof() .AND. SA2->A2_FILIAL == xFilial('SA2') .AND. SubStr(SA2->A2_CGC,1,nLenCNPJ) == ALLTRIM(cCnPj)
                   aAdd(aRet,{'SA2',SA2->A2_COD,SA2->A2_LOJA})
                   SA2->(dbSkip())
                Enddo   
             EndIf

        Case aAlias[i,1] == 'SA4'  // TRANSPORTADORA           
             DbSelectArea('SA4') 
             DbSetOrder(3)
             If DbSeek(xFilial('SA4')+cCnpj) 
                Do While ! Eof() .AND. SA4->A4_FILIAL == xFilial('SA4') .AND. SubStr(SA4->A4_CGC,1,nLenCNPJ) == ALLTRIM(cCnPj)
                   aAdd(aRet,{'SA4',SA4->A4_COD,''})
                   SA4->(dbSkip())
                Enddo   
             EndIf

        Case aAlias[i,1] == 'SUS'  // PROSPECTS
             DbSelectArea('SUS') 
             DbSetOrder(4)
             If DbSeek(xFilial('SUS')+cCnpj) 
                Do While ! Eof() .AND. SUS->US_FILIAL == xFilial('SUS') .AND. SubStr(SUS->US_CGC,1,nLenCNPJ) == ALLTRIM(cCnPj)
                   aAdd(aRet,{'SUS',SUS->US_COD,SUS->US_LOJA})
                   SUS->(dbSkip())
                Enddo   
             EndIf

        EndCase        

Next      

RestArea(aAreaSX5)
RestArea(aAreaACH)
RestArea(aAreaSA1)
RestArea(aAreaSA2)
RestArea(aAreaSA4)
RestArea(aAreaSUS)
RestArea(aSavArea)

Return(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTkEntSel  บAutor  ณVendas Clientes     บ Data ณ  07/02/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPermite Selecao de Entidade Localizada pela pesquisa de CNPJบฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpA1 - Lista de Cnpj's encontrados                         บฑฑ
ฑฑบ          ณExpC2 - Alias da entidade                                   บฑฑ
ฑฑบ          ณExpC3 - Codigo da entidade                                  บฑฑ
ฑฑบ          ณExpC4 - Loja da entidade                                    บฑฑ
ฑฑบ          ณExpA5 - Lista de entidades disponiveis                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณCall Center                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function TkEntSel(	aCnpj		, cEntidade	, cCodigo	, cLoja	,;
							aEntidades	)

Local aSavArea := GetArea()
Local aAreaACH := ACH->(GetArea()) // SUSPECTS 
Local aAreaSA1 := SA1->(GetArea()) // CLIENTES
Local aAreaSA2 := SA2->(GetArea()) // FORNECEDORES   
Local aAreaSA4 := SA4->(GetArea()) // TRANSPORTADORAS
Local aAreaSUS := SUS->(GetArea()) // PROSPECTS
Local aPDCols  := {}		
Local cRazao   := ""
Local cFantasia:= ""
Local cEndereco:= ""
Local cBairro  := ""
Local cCep     := ""
Local cFone    := ""
Local lRet     := .F.
Local aTMKEnti := {}
Local i    	   := 0
Local oEntid 
Local oDlgSel
Local aRetPE := Nil

// Ponto de entrada para tratamento dos CNPJs selecionados
If _lTkVlSele
	aRetPE := Execblock("TKVLSELE",.F.,.F.,{aCNPJ})
	If ValType(aRetPE) == "A" 
		aCNPJ := aRetPE
	EndIf
EndIf

// Se existirem entidades localizadas
If Len(aCNPJ) > 0

	cRazao   := ""
	cFantasia:= ""
	cEndereco:= ""
	cBairro  := ""
	cCep     := ""
	cFone    := ""
	
	For i:= 1 to Len(aCNPJ)

	    Do Case

		   Case aCNPJ[i,1] == 'ACH'  // SUSPECTS 
	            DbSelectArea('ACH') 
	            DbSetOrder(1)
	            If DbSeek(xFilial('ACH')+aCnpj[i,2]+aCnpj[i,3])
					cRazao   := ACH->ACH_RAZAO
					cFantasia:= ACH->ACH_NFANT
					cEndereco:= ACH->ACH_END
					cBairro  := ACH->ACH_BAIRRO
					cCep     := ACH->ACH_CEP
					cFone    := ACH->ACH_TEL 
	            EndIf
	
	       Case aCNPJ[i,1] == 'SA1'  // CLIENTES
	            DbSelectArea('SA1') 
	            DbSetOrder(1)
	            If DbSeek(xFilial('SA1')+aCnpj[i,2]+aCnpj[i,3]) 
					cRazao   := SA1->A1_NOME
					cFantasia:= SA1->A1_NREDUZ
					cEndereco:= SA1->A1_END
					cBairro  := SA1->A1_BAIRRO
					cCep     := SA1->A1_CEP
					cFone    := SA1->A1_TEL
	            EndIf
	
	       Case aCNPJ[i,1] == 'SA2'  // FORNECEDORES   
	            DbSelectArea('SA2') 
	            DbSetOrder(1)
	            If DbSeek(xFilial('SA2')+aCnpj[i,2]+aCnpj[i,3]) 
					cRazao   := SA2->A2_NOME
					cFantasia:= SA2->A2_NREDUZ
					cEndereco:= SA2->A2_END
					cBairro  := SA2->A2_BAIRRO
					cCep     := SA2->A2_CEP
					cFone    := SA2->A2_TEL
	            EndIf
	
		   Case aCNPJ[i,1] == 'SA4'  // TRANSPORTADORAS
	             DbSelectArea('SA4') 
	             DbSetOrder(1)
	             If DbSeek(xFilial('SA4')+aCnpj[i,2]) // Nao possui Loja no Indice Padrao 
					cRazao   := SA4->A4_NOME
					cFantasia:= SA4->A4_NREDUZ
					cEndereco:= SA4->A4_END
					cBairro  := SA4->A4_BAIRRO
					cCep     := SA4->A4_CEP
					cFone    := SA4->A4_TEL
	             EndIf
	
		   Case aCNPJ[i,1] == 'SUS'  // PROSPECTS
	             DbSelectArea('SUS') 
	             DbSetOrder(1)
	             If DbSeek(xFilial('SUS')+aCnpj[i,2]+aCnpj[i,3]) 
					cRazao   := SUS->US_NOME
					cFantasia:= SUS->US_NREDUZ
					cEndereco:= SUS->US_END
					cBairro  := SUS->US_BAIRRO
					cCep     := SUS->US_CEP
					cFone    := SUS->US_TEL
	             EndIf
	             
	    EndCase
	    
       // Adiciona dados no Array para ListBox
  	   aAdd(aTMKEnti,{aCnpj[i,1],aCnpj[i,2],aCnpj[i,3],cRazao,cFantasia,cEndereco,cBairro,cCep,cFone})

	Next
	
	// Analisa prioridade de entidades se existir entidade Cliente elimina Propect e Suspect
	// Pois Cliente tem prioridade sobre os mesmos

	If aScan(aTMKEnti,{|x| x[1] == 'SA1'}) > 0

	   If aScan(aTMKEnti,{|x| x[1] == 'SUS'}) > 0 // Elimina PROSPECT
	      aDel(aTMKEnti,aScan(aTMKEnti,{|x| x[1] == 'SUS'}))
          aSize(aTMKEnti,LEN(aTMKEnti)-1)
	   Endif   

	   If aScan(aTMKEnti,{|x| x[1] == 'ACH'}) > 0 // Elimina SUSPECT
	      aDel(aTMKEnti,aScan(aTMKEnti,{|x| x[1] == 'ACH'}))
          aSize(aTMKEnti,LEN(aTMKEnti)-1)
	   Endif   
	
	Endif
	
	// Analisa prioridade de entidades se existir entidade Prospect elimina e Suspect
	// Pois Prospect tem prioridade sobre Suspect

	If aScan(aTMKEnti,{|x| x[1] == 'SUS'}) > 0

	   If aScan(aTMKEnti,{|x| x[1] == 'ACH'}) > 0 // Elimina SUSPECT
	      aDel(aTMKEnti,aScan(aTMKEnti,{|x| x[1] == 'ACH'}))
          aSize(aTMKEnti,LEN(aTMKEnti)-1)
	   Endif   
	
	Endif

	// Se existir entidades para ListBox

    If Len(aTMKEnti) > 0

	    // Se existir somente uma entidade localizada retornar os dados direto
	
		If Len(aTMKEnti) == 1
		
			lRet		:= .T.
			cEntidade	:= aTMKEnti[1,1]
			cCodigo		:= aTMKEnti[1,2]
			cLoja		:= aTMKEnti[1,3]
			
		Else
			
			// Se existirem 2 ou mais entidades abrir tela para selecao
		
			DEFINE MSDIALOG oDlgSel TITLE STR0051 FROM 00,00 TO 250,717 PIXEL 	//"Selecao de Entidade"
		
			@02,02 TO 120,325 LABEL "" PIXEL OF oDlgSel
			@05,04 LISTBOX oEntid FIELDS ;
						HEADER ;  	
						STR0009,;	//"Entidade"  
						STR0052,;	//"Codigo"
						STR0010,; 	//"Loja"
						STR0053,;	//"Razใo"
						STR0054,;	//"Nome Fantasia"
						STR0055,;	//"Endere็o"
						STR0056,;	//"Bairro"
						STR0057,;	//"CEP"
						STR0058;	//"Fone"
						ON DbLCLICK ( 	lRet		:= .T.,;
										cEntidade	:= aTMKEnti[oEntid:nAt,1],;
										cCodigo		:= aTMKEnti[oEntid:nAt,2],;
										cLoja  		:= aTMKEnti[oEntid:nAt,3],;
										oDlgSel:End() );
										SIZE 320,115 OF oDlgSel PIXEL NOSCROLL
			oEntid:SetArray(aTMKEnti)
			oEntid:bLine:={||{ aEntidades[aScan(aEntidades,{|x| AllTrim(x[1]) == AllTrim(aTMKEnti[oEntid:nAt,1])})][2],; // Entidade 	
							   aTMKEnti[oEntid:nAt,2],; // Codigo
							   aTMKEnti[oEntid:nAt,3],; // Loja
							   aTMKEnti[oEntid:nAt,4],; // Razใo Social
							   aTMKEnti[oEntid:nAt,5],; // Fantasia
							   aTMKEnti[oEntid:nAt,6],;	 // Endere็o
							   aTMKEnti[oEntid:nAt,7],;	 // Bairro
							   aTMKEnti[oEntid:nAt,8],;	 // Cep
							   aTMKEnti[oEntid:nAt,9]}}	 // Fone	

			aPDCols := {"","","","A1_NOME","A1_NREDUZ","A1_END","A1_BAIRRO","A1_CEP","A1_TEL"}  

			If FATPDActive() .And. FTPDUse(.T.)  							
				oEntid:aObfuscatedCols := FATPDColObfuscate(aPDCols)
			EndIf
							   
			oEntid:Refresh()
		
			DEFINE SBUTTON FROM 05,328 TYPE 1 ENABLE OF oDlgSel ACTION ;
										(	lRet		:= .T.,;
											cEntidade	:= aTMKEnti[oEntid:nAt,1],;
											cCodigo		:= aTMKEnti[oEntid:nAt,2],;
											cLoja		:= aTMKEnti[oEntid:nAt,3],;
											oDlgSel:End() )
			DEFINE SBUTTON FROM 18,328 TYPE 2 ENABLE OF oDlgSel ACTION oDlgSel:End()
		
			ACTIVATE MSDIALOG oDlgSel CENTERED
	
		Endif

	Endif

Endif

RestArea(aAreaACH)
RestArea(aAreaSA1)
RestArea(aAreaSA2)
RestArea(aAreaSA4)
RestArea(aAreaSUS)
RestArea(aSavArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTmkVeEnt  บAutor  ณVendas Clientes     บ Data ณ  11/02/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica existencia de Entidades, retorna .F. para caso a   บฑฑ
ฑฑบ          ณentidade seja localizada.                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1 - CNPJ a ser pesquisado                               บฑฑ
ฑฑบ          ณExpC2 - Alias da entidade atual                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณCALL CENTER                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function TmkVeEnt(cCnpj,cEntAtu)

Local aArea		:= {}								// Posicionamento da tabela atual
Local aAreaBkp	:= {}								// Posicionamento das tabelas das entidades
Local aEntAva	:= {"SA1","SUS","ACH"}				// Lista de entidades avaliadas
Local lRet		:= .T.								// Retorno da funcao
Local aFilBkp	:= {}								// Backup de filtros
Local cCodEnt	:= ""								// Codigo da entidade
Local cLojEnt	:= ""								// Loja da entidade
Local cFiltro	:= ""								// Filtro atual
Local i			:= 1								// Auxiliar de loop
Local nPos		:= 0								// Indice para posicionamento no array aTmkEnti
Local aTMKEnti	:= {}								// Lista de entidades encontradas com o CGC atual
Local lValida	:= SuperGetMv("MV_TMKVCGC",,.T.)	// Indica se o CGC deve ser validado entre as entidades

If lValida
	
	aArea	:= GetArea()      
	
	For i := 1 to Len(aEntAva)
		DbSelectArea(aEntAva[i])
		aAdd(aAreaBkp,GetArea())
		If !Empty(cFiltro := DbFilter()) 
			AAdd(aFilBkp,{aEntAva[i],cFiltro})
			DbClearFilter()
		EndIf			
	Next i
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณIdentifica ocorrencia das entidades para o CNPJณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aTMKEnti:=TBuscaCNPJ(cCnpj)
	    
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVerifica se existe alguma entidade com o mesmo CNPJ semณ
	//ณque esta seja a evolucao da propria entidade           ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
	i := 1       
	
	While (i <= Len(aTMKEnti)) .AND. (lRet)      
		
		Do Case
			
			//Entidade: Cliente - Ocorrencia: Cliente
			Case cEntAtu == "SA1" .AND. aTMKEnti[i][1] == "SA1"
 
 				lRet := (aTmkEnti[i][2] == M->A1_COD) .AND. (aTmkEnti[i][3] == M->A1_LOJA)

 			//Entidade: Cliente - Ocorrencia: Prospect
			Case cEntAtu == "SA1" .AND. aTMKEnti[i][1] == "SUS"

				DbSelectArea("SUS")
				DbSetOrder(1)
				
                If DbSeek(xFilial("SUS")+aTMKEnti[i][2]+aTMKEnti[i][3])
					lRet := SUS->US_CODCLI == M->A1_COD .AND. SUS->US_LOJACLI == M->A1_LOJA
				Else
					lRet := .F.
				EndIF
			
			//Entidade: Cliente - Ocorrencia: Suspect
			Case cEntAtu == "SA1" .AND. aTMKEnti[i][1] == "ACH"
				             
				DbSelectArea("ACH")
				DbSetOrder(1) 
				
				If DbSeek(xFilial("ACH")+aTMKEnti[i][2]+aTMKEnti[i][3])
					cCodEnt	:= ACH->ACH_CODPRO
					cLojEnt	:= ACH->ACH_LOJPRO
				Else
					lRet := .F.
				EndIf 
				
				If !Empty(cCodEnt)
					DbSelectArea("SUS")
					DbSetOrder(1)
					If DbSeek(xFilial("SUS")+cCodEnt+cLojEnt)
						lRet := SUS->US_CODCLI == M->A1_COD .AND. SUS->US_LOJACLI == M->A1_LOJA
					Else
						lRet := .F.
					EndIf
				Else
					lRet := .F.
				EndIf

			//Entidade: Prospect - Ocorrencia: Cliente
			Case cEntAtu == "SUS" .AND. aTMKEnti[i][1] == "SA1" 
				lRet := (M->US_CODCLI == aTMKEnti[i][2]) .AND. (M->US_LOJACLI == aTMKEnti[i][3])
			
			//Entidade: Prospect - Ocorrencia: Prospect
			Case cEntAtu == "SUS" .AND. aTMKEnti[i][1] == "SUS" 
				lRet := (aTmkEnti[i][2] == M->US_COD) .AND. (aTmkEnti[i][3] == M->US_LOJA)
			
			//Entidade: Prospect - Ocorrencia: Suspect
			Case cEntAtu == "SUS" .AND. aTMKEnti[i][1] == "ACH"
			 
				DbSelectArea("ACH")
				DbSetOrder(1) 
				
				If DbSeek(xFilial("ACH")+aTMKEnti[i][2]+aTMKEnti[i][3])
					lRet := (ACH->ACH_CODPRO == M->US_COD) .AND. (ACH->ACH_LOJPRO == M->US_LOJA)
				Else
					lRet := .F.
				EndIf 
				

			//Entidade: Suspect - Ocorrencia: Cliente
			Case cEntAtu == "ACH" .AND. aTMKEnti[i][1] == "SA1"

				DbSelectArea("SUS")
				DbSetOrder(1)      
				
				If DbSeek(xFilial("SUS")+M->ACH_CODPRO+M->ACH_LOJPRO)
					lRet := (SUS->US_CODCLI == aTMKEnti[i][2]) .AND. (SUS->US_LOJACLI == aTMKEnti[i][3])
				Else
					lRet := .F.
				EndIf
			
			//Entidade: Suspect - Ocorrencia: Prospect
			Case cEntAtu == "ACH" .AND. aTMKEnti[i][1] == "SUS" 
		   		lRet := (M->ACH_CODPRO == aTMKEnti[i][2]) .AND. (M->ACH_LOJPRO == aTMKEnti[i][3])
			
			//Entidade: Suspect - Ocorrencia: Suspect
			Case cEntAtu == "ACH" .AND. aTMKEnti[i][1] == "ACH"  
				lRet := (aTmkEnti[i][2] == M->ACH_CODIGO) .AND. (aTmkEnti[i][3] == M->ACH_LOJA)			
				
		EndCase		
		
		i++
		
	End
	
	If ! lRet
		Help('',1,'TMKVEENT')
	Endif 
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณRestaura filtros e posicionamentosณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	For i := 1 to Len(aEntAva) 
	
		nPos := aScan(aFilBkp,{|x|x[1] == aEntAva[i]})
	
		If nPos > 0
			DbSelectArea(aEntAva[i]) 
			cFiltro	:= aFilBkp[nPos][2]
			SET FILTER TO &cFiltro
		EndIf			

		RestArea(aAreaBkp[i])

	Next i
	     
	RestArea(aArea)  
	
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTkCanDelU5บAutor  ณVendas CRM          บ Data ณ  04/07/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida a exclusao de um contato relacionado a uma entidade  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTMKXFUNE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function TkCanDelU5(oGetSU5)

Local lRet 		:= .T.
Local aArea		:= GetArea()
Local aAreaSM0	:= SM0->(GetArea())
Local aAreaADE	:= ADE->(GetArea())
Local aSM0CodFil:= {}   
Local nBusca	:= 0
Local nPosCont	:= aScan(oGetSU5:aHeader,{|x| AllTrim(x[2]) == "U5_CODCONT"})
Local cContato	:= oGetSU5:aCols[oGetSU5:nAt][nPosCont]

// Preenche um array com as filiais
DbSelectArea("SM0")
DbGoTop()
Do While ! Eof()
	If SM0->M0_CODIGO == cEmpAnt
		Aadd(aSM0CodFil,SM0->M0_CODFIL)
	Endif
	dbSkip()
End	
	
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica se existe Atendimento para o contato ADE            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("ADE")
DbSetOrder(14)
aFiliais := If( FWModeAccess("ADE",3) == "E" .AND. FWModeAccess("SU5",3) == "C", aClone(aSM0CodFil), {xFilial()})
For nBusca := 1 To Len(aFiliais)
   	If DbSeek(aFiliais[nBusca]+cContato)
      	Help(" ",1,"TMKNDELADE")
   		lRet := .F. 
   		Exit
	EndIf
Next

RestArea(aAreaSM0)
RestArea(aAreaADE)
RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณBuscaContatoบAutor  ณMicrosiga           บ Data ณ  16/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณBusca os possiveis contatos cadastrados conforme chave de     บฑฑ
ฑฑบ          ณpesquisa                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function BuscaContato(cChavePesq,nOpcPesq,aContatos,oListContatos)

Local aArea		:= GetArea()
Local cQuerySU5	:= ""
Local aRetBusCon	:= Nil

Default cChavePesq	:= ""
Default nOpcPesq 	:= 1

cChavePesq := AllTrim(cChavePesq)

If Len(cChavePesq) < 3
	MsgInfo(STR0076) //"O texto para pesquisa deve conter ao menos 3 caracteres"
	Return Nil
endIf

aContatos := {}

//Busca os contatos
cQuerySU5 := " SELECT U5_CODCONT, U5_CONTAT, AC8_ENTIDA, AC8_CODENT "
cQuerySU5 += " FROM " + RetSQLName("SU5") + " SU5, " + RetSQLName("AC8") + " AC8 "
cQuerySU5 += " WHERE U5_FILIAL = '" + xFilial("SU5") + "' AND SU5.D_E_L_E_T_ = ' ' AND "
cQuerySU5 += "       AC8_FILIAL = '" + xFilial("AC8") + "' AND AC8_CODCON = U5_CODCONT AND AC8.D_E_L_E_T_ = ' ' "

If nOpcPesq == 1 //Por Nome
	cQuerySU5 += "       AND UPPER(U5_CONTAT) LIKE '" + Upper(cChavePesq) + "%' "
ElseIf nOpcPesq == 2  //Por E-Mail
	cQuerySU5 += "       AND UPPER(U5_EMAIL) LIKE '" + Upper(cChavePesq) + "%' "
ElseIf nOpcPesq == 3 //Por Codigo
	cQuerySU5 += "       AND UPPER(U5_CODCONT) LIKE '" + Upper(cChavePesq) + "%' "
ElseIf nOpcPesq == 4 //Por CPF/CNPJ
	cQuerySU5 += "       AND U5_CPF LIKE '" + cChavePesq + "%' "
EndIf
cQuerySU5 := ChangeQuery(cQuerySU5)

Iif(Select("TRB_SU5") > 0, TRB_SU5->(dbCloseArea()),Nil)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuerySU5),"TRB_SU5",.T.,.T.)
dbSelectArea("TRB_SU5")

If TRB_SU5->(!Eof())
	While TRB_SU5->(!Eof())
		AAdd(aContatos,{	TRB_SU5->U5_CODCONT,;
							TRB_SU5->U5_CONTAT,;
							Posicione("SX2",1,TRB_SU5->AC8_ENTIDA,"SX2->X2_NOME"),;
							TRB_SU5->AC8_CODENT,;
							TkEntidade(TRB_SU5->AC8_ENTIDA,AllTrim(TRB_SU5->AC8_CODENT),1),;
							TRB_SU5->AC8_ENTIDA})
		TRB_SU5->(dbSkip())
	EndDo 
	TRB_SU5->(dbCloseArea())
	

	// Ponto de entrada criado avaliar os contatos retornados pela busca de contatos no folder 2 da sele็ใo de entidades.
	If _lTkBusCon
		aRetBusCon := Execblock( "TKBUSCON" , .F. , .F. , { aContatos } )
		If ValType(aRetBusCon) == "A" 
			aContatos := aRetBusCon
		EndIf
	EndIf
	
Else
	AAdd(aContatos,{"",STR0077,"","","",""}) //"NENHUM CONTATO LOCALIZADO"
EndIf

oListContatos:SetArray(aContatos)                                                                            
oListContatos:bLine := {||{	aContatos[oListContatos:nAt][1],;
							aContatos[oListContatos:nAt][2],;
							aContatos[oListContatos:nAt][3],;
							aContatos[oListContatos:nAt][4],;
							aContatos[oListContatos:nAt][5],;
							aContatos[oListContatos:nAt][6]}}
oListContatos:Refresh() 
RestArea(aArea)

Return Nil
 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTkContDireto บAutor  ณBruno Daniel Borges บ Data ณ  16/08/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao que exibe as entidades relacionadas ao contato para     บฑฑ
ฑฑบ          ณescolha                                                        บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function TkContDireto()  

Local oDlg   := Nil
Local oLbx   := Nil
Local nPos 	 := 0
Local nOpcao := 0  
Local aCont  := {}
Local aSX5T5 := LoadVetSX5()
Local aPDFields := {"A1_NOME"}
Local aPDCols := {"","","A1_NOME"}

If !__lF3Contato .AND. !IsInCallStack("ENCHAUTO") .AND. !IsInCallStack("DUPLICATE")

	FATPDLoad(Nil, Nil, aPDFields)

	dbSelectArea("AC8")
	AC8->(dbSetOrder(1))
	AC8->(dbSeek(xFilial("AC8")+M->ADE_CODCON ))
	While AC8->(!Eof()) .And. AC8->AC8_FILIAL  == xFilial("AC8") .AND. AC8->AC8_CODCON == M->ADE_CODCON .AND. (ASCAN(aSX5T5,{|e| e == AC8->AC8_ENTIDA})>0)
		AAdd(aCont,{	AC8->AC8_ENTIDA,;
						AC8->AC8_CODENT,;
						Posicione("SX2",1,AC8->AC8_ENTIDA,"SX2->X2_NOME"),;
						TkEntidade( AC8->AC8_ENTIDA, AllTrim(AC8->AC8_CODENT), 1 )})
	     
		AC8->(dbSkip())
	EndDo
	
	If Len(aCont) <= 0
		AAdd(aCont,{"","","",STR0078}) //"CONTATO NรO ASSOCIADO A ENTIDADES DO SISTEMA"
	EndIf
	
	//Apenas apresenta a tela se houver mais de uma ocorrencia
	If Len(aCont) > 1
		While nOpcao == 0 
			DEFINE MSDIALOG oDlg FROM  300,20 TO 560,650 TITLE STR0079 PIXEL //"Relacionamento Contatos X Entidades"
				@01,03 TO 110,315 LABEL "" OF oDlg  PIXEL
				@05,05 LISTBOX oLbx FIELDS HEADER ;
						STR0073,;	//"Entidade"
						STR0071,;	//"C๓digo"
						STR0075;	//"Desc. Entidade"
						SIZE 307,103 NOSCROLL OF oDlg PIXEL; 
					 	ON DBLCLICK(nOpcao :=1 , nPos := oLbx:nAt ,oDlg:End()) 
				oLbx:SetArray(aCont)
				oLbx:bLine:={||{aCont[oLbx:nAt,3],;
								aCont[oLbx:nAt,2],;								
								aCont[oLbx:nAt,4] }}
									
				oLbx:nAt := 1

				If FATPDActive() .And. FTPDUse(.T.)				  							
					oLbx:aObfuscatedCols := FATPDColObfuscate(aPDCols)
				EndIf

				DEFINE SBUTTON FROM 115,005 TYPE 1	ENABLE OF oDlg ACTION (nOpcao:=1, nPos:=oLbx:nAt, oDlg:End())
				DEFINE SBUTTON FROM 115,040 TYPE 2 	ENABLE OF oDlg ACTION (nOpcao:=0,oDlg:End())

				FATPDLogUser("TKCONTDIRE")                      
				
			ACTIVATE MSDIALOG oDlg CENTER   
			If nOpcao <> 1
				MsgInfo(STR0080) //"Selecione a entidade deste contato"
			EndIf
		End
	Else
		nPos 	:= 1
	EndIf
	
	M->ADE_CODCON	:= M->ADE_CODCON
	M->ADE_NMCONT	:= TkDadosContato(M->ADE_CODCON,0)
	M->ADE_ENTIDAD	:= aCont[nPos,1]
	M->ADE_NMENT	:= Posicione("SX2",1,aCont[nPos,1],"X2NOME()")       	//Cadastro de Clientes
	M->ADE_DESCIN	:= ALLTRIM(Posicione("SIX",1,AllTrim(aCont[nPos,2])+ "1","SIXDescricao()"))        //Codigo + Loja
	M->ADE_CHAVE  	:= Alltrim(aCont[nPos,2])
	M->ADE_DESCCH	:= TkEntidade(aCont[nPos,1],AllTrim(aCont[nPos,2]),1) 	   //Empresa X Ltda.

	FATPDUnload()

EndIf
                  
//Restaura a variavel de controle de digitacao direta sem passar pelo F3
__lF3Contato := .F.

Return(M->ADE_CODCON)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTMKXFUNE  บAutor  ณMicrosiga           บ Data ณ  08/11/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function LoadVetSX5()
Local aRet		:= {}
Local aGetArea	:= GetArea()

DbSelectArea("SX5")      
SX5->(DbSetOrder(1))
If SX5->(DbSeek(xFilial("SX5")+"T5"))
   While SX5->(!eof()) .and. Alltrim(SX5->X5_TABELA) == "T5"
         aAdd(aRet,Alltrim(SX5->X5_CHAVE))
         SX5->(DbSkip()) 
   EndDo
EndIf

RestArea(aGetArea)

Return aRet

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLoad
    @description
    Inicializa variaveis com lista de campos que devem ser ofuscados de acordo com usuario.
	Remover essa fun็ใo quando nใo houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cUser, Caractere, Nome do usuแrio utilizado para validar se possui acesso ao 
        dados protegido.
    @param aAlias, Array, Array com todos os Alias que serใo verificados.
    @param aFields, Array, Array com todos os Campos que serใo verificados, utilizado 
        apenas se parametro aAlias estiver vazio.
    @param cSource, Caractere, Nome do recurso para gerenciar os dados protegidos.
    
    @return cSource, Caractere, Retorna nome do recurso que foi adicionado na pilha.
    @example FATPDLoad("ADMIN", {"SA1","SU5"}, {"A1_CGC"})
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDLoad(cUser, aAlias, aFields, cSource)
	Local cPDSource := ""

	If FATPDActive()
		cPDSource := FTPDLoad(cUser, aAlias, aFields, cSource)
	EndIf

Return cPDSource

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDUnload
    @description
    Finaliza o gerenciamento dos campos com prote็ใo de dados.
	Remover essa fun็ใo quando nใo houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cSource, Caractere, Remove da pilha apenas o recurso que foi carregado.
    @return return, Nulo
    @example FATPDUnload("XXXA010") 
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDUnload(cSource)    

    If FATPDActive()
		FTPDUnload(cSource)    
    EndIf

Return Nil

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDIsObfuscate
    @description
    Verifica se um campo deve ser ofuscado, esta fun็ใo deve utilizada somente ap๓s 
    a inicializa็ใo das variaveis atravez da fun็ใo FATPDLoad.
	Remover essa fun็ใo quando nใo houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cField, Caractere, Campo que sera validado
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado
    @return lObfuscate, L๓gico, Retorna se o campo serแ ofuscado.
    @example FATPDIsObfuscate("A1_CGC",Nil,.T.)
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDIsObfuscate(cField, cSource, lLoad)
    
	Local lObfuscate := .F.

    If FATPDActive()
		lObfuscate := FTPDIsObfuscate(cField, cSource, lLoad)
    EndIf 

Return lObfuscate

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDColObfuscate
    @description
    Verifica se a coluna de um grid deve ser ofuscado, tendo como base uma lista de
    campos, esta fun็ใo deve utilizada somente ap๓s a inicializa็ใo das variaveis 
    atravez da fun็ใo FATPDLoad.
	Remover essa fun็ใo quando nใo houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cField, Caractere, Campo que sera validado
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.

    @return lObfuscate, L๓gico, Retorna se o campo serแ ofuscado.
    @example FATPDIsObfuscate({"A1_COD","A1_NOME","A1_CGC"})
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDColObfuscate(aFields, cSource)  
    
	Local aPDColObf	:= {}

    If FATPDActive()
		aPDColObf := FTPDColObfuscate(aFields, cSource)  
    EndIf 

Return aPDColObf

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLogUser
    @description
    Realiza o log dos dados acessados, de acordo com as informa็๕es enviadas, 
    quando a regra de auditoria de rotinas com campos sensํveis ou pessoais estiver habilitada
	Remover essa fun็ใo quando nใo houver releases menor que 12.1.27

   @type  Function
    @sample FATPDLogUser(cFunction, nOpc)
    @author Squad CRM & Faturamento
    @since 06/01/2020
    @version P12
    @param cFunction, Caracter, Rotina que serแ utilizada no log das tabelas
    @param nOpc, Numerico, Op็ใo atribuํda a fun็ใo em execu็ใo - Default=0

    @return lRet, Logico, Retorna se o log dos dados foi executado. 
    Caso o log esteja desligado ou a melhoria nใo esteja aplicada, tamb้m retorna falso.

/*/
//-----------------------------------------------------------------------------
Static Function FATPDLogUser(cFunction, nOpc)

	Local lRet := .F.

	If FATPDActive()
		lRet := FTPDLogUser(cFunction, nOpc)
	EndIf 

Return lRet  

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Fun็ใo que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive