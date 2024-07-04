#include "FINA085P.CH"
#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/12/99

STATIC lMod2	:= .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ FUNCAO   ³ FINA085P ³ AUTOR ³ Leonardo Ruben        ³ DATA ³ 30.12.99   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ DESCRICAO³ Elaborar/Cancelar PRE-Orden de Pago                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ USO      ³ Generico - Localizacoes   (ex-PAGO030.PRX na v.407)          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fina085P()
Local cfilpg085p

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("LINVERTE,CMARCAE2,NLASTKEY,LFILTRA,ACAMPOS,CINDEX")
SetPrvt("CKEY,CCONDICAO,NINDEX,NSAVEORDER,CCADASTRO,APOS")
SetPrvt("AROTINA,_SALIAS,CPERG,AREGS,NA,NB")
PRIVATE bFiltraBrw := {|| Nil}
Private aIndexSE2	:= {}
Private cPagaveis	:=	""

/*
 * Verificação do processo que está configurado para ser utilizado no Módulo Financeiro (Argentina)
 */
If lMod2
	If !FinModProc()
		Return()
	EndIf
EndIf

//+--------------------------------------------------------------+
//¦ Verifica as perguntas           									  ¦
//+--------------------------------------------------------------+

lInverte := .F.
cMarcaE2 := ""
nLastKey :=	0
//+--------------------------------------------------------------+
//¦ Variaveis utilizadas para parametros						 ¦
//¦ mv_par01	  // Filtra já generadas 	 - Sim/Nao			 ¦
//¦ mv_par02 	  // Trazer Facturas Marc   - Sim/Nao			 ¦
//¦ mv_par03     // Del Vencimiento                              ¦
//¦ mv_par04	  // Hasta										 ¦
//¦ mv_par05     // Del Proveedor                                ¦
//¦ mv_par06     // Hasta                                        ¦
//¦ mv_par07     // De la Sucursal                               ¦
//¦ mv_par08     // Hasta                                        ¦
//+--------------------------------------------------------------+
IF !Pergunte("PAG030",.T.)
	Return
Endif

If nLastKey == 27
	Return
Endif

lFiltra   := If( MV_PAR01==1,.T.,.F.)  // Filtra ja emitida
lInverte  := If( MV_PAR02==1,.T.,.F.)  // Traz os facturas marcadas


// ALterado para pegar campos em uso do SE2   Paulo 27/11/2000

aCampos:= {	{"E2_OK"     ,"","  "}}
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek( "SE2" )
nUsado := 0
While ! Eof() .and. ( x3_arquivo == "SE2" )
	If X3uso(x3_usado) .and. cNivel >= x3_nivel .and. x3_browse=="S" .and. !(trim(x3_campo)="E2_OK")
		nUsado++
		AADD(aCampos,{  x3_campo,"", TRIM(X3Titulo()),x3_picture } )
	EndIf
	dbSkip()
End
//+--------------------------------------------------------------+
//¦ Punto de entrada para filtrar el SE2 por el usuario.			  ¦
//+--------------------------------------------------------------+
If ExistBlock("Pago085p")
	cFilPg085p	:=	Execblock("Pago085p",.F.,.F.)
Else
	cFilPg085p	:=	""
Endif
//+--------------------------------------------------------------+
//¦ Cria Indice Condicional para o MARKBROWSE.						  ¦
//+--------------------------------------------------------------+
cIndex := CriaTrab(Nil,.f.)
dbSelectArea("SE2")
dbSetOrder(1)
#IFDEF TOP
	cKey := "E2_FILIAL+E2_FORNECE+E2_LOJA+E2_VENCREA"
#ELSE
	cKey := "E2_FILIAL+E2_FORNECE+E2_LOJA+DTOS(E2_VENCREA)"
#ENDIF

cPagaveis	:=	GetSESTipos({|| ES_BXRCOP == "1"},"2")
cPagaveis	:=	IIf(Empty(cPagaveis),MVNOTAFIS+"/"+MVPAGANT,cPagaveis)

cCondicao := 'E2_FILIAL=="'+xFilial("SE2")+'"'
cCondicao := cCondicao + '.And.E2_FORNECE>="'+mv_par05+'".And.E2_FORNECE<="'+mv_par06+'"'
cCondicao := cCondicao + '.And.E2_LOJA>="'+mv_par07+'".And.E2_LOJA<="'+mv_par08+'"'
cCondicao := cCondicao + '.And.DTOS(E2_VENCREA)>="'+DtoS(mv_par03)+'".And.DTOS(E2_VENCREA)<="'+DtoS(mv_par04)+'".And.Dtos(E2_EMISSAO)<="'+dTos(dDataBase) + '"'
cCondicao := cCondicao + ".AND.E2_TIPO $'"+cPagaveis+"'"
cCondicao := cCondicao + '.And.E2_SALDO>0'


If !Empty(cFilPg085p)
	cCondicao	+=	".And." + cFilPg085P
Endif

If lFiltra
	cCondicao := cCondicao + '.And.E2_PREOK<>"S"'
EndIf

dbGoTop()
nSaveOrder:=Indexord()
If BOF() .and. EOF()
	Help(" ",1,"RECNO")
Else
	cCadastro := OemToAnsi(STR0013)  //"PRE-Orden de Pago"
	aPos:= {  8,  4, 11, 74 }

	Private aRotina := MenuDef()

	cMarcaE2 := GetMark()
	bFiltraBrw 	:= {|| FilBrowse("SE2",@aIndexSE2,@cCondicao) }
	Eval(bFiltraBrw)
	MarkBrow("SE2","E2_OK",'E2_PREOK=="S"',aCampos,lInverte,cMarcaE2,,,'xFilial("SE2")','xFilial("SE2")')
	EndFilBrw("SE2",aIndexSE2)
EndIf

Retindex("SE2")
// FERASE(cIndex+OrdBagExt())
Return


/*
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ PAGO032  ¦ Autor ¦ Leonardo Ruben        ¦ Data ¦ 29.12.99 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ AxPesqui para PRE-ordem de pagamento por fornecedor        ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Pago030                                                    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Function a085PPesq()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("CCAMPO,CORD,AORD,")

cCampo := CriaVar("E2_FORNECE",.F.)
cOrd   := OemToAnsi(STR0008) //"Proveedor"
aOrd   :={}
Aadd(aOrd,OemToAnsi(STR0008))  //"Proveedor"
@ 5, 5 TO 68, 400 DIALOG oDlg TITLE OemToAnsi(STR0014) //"Buscar"
@ 1.6 , 002 COMBOBOX cOrd ITEMS aOrd  SIZE 165,44
@ 15  , 002 GET cCampo SIZE 165,10
@ 1.6 , 170 BMPBUTTON TYPE 1 ACTION Buscar()// Substituido pelo assistente de conversao do AP5 IDE em 29/12/99 ==> @ 1.6 , 170 BMPBUTTON TYPE 1 ACTION Execute(Buscar)
@ 14.6, 170 BMPBUTTON TYPE 2 ACTION Salir()// Substituido pelo assistente de conversao do AP5 IDE em 29/12/99 ==> @ 14.6, 170 BMPBUTTON TYPE 2 ACTION Execute(Salir)
ACTIVATE DIALOG oDlg CENTERED
Return

// Substituido pelo assistente de conversao do AP5 IDE em 29/12/99 ==> Function Buscar
Static Function Buscar()
DbSelectArea("SE2")
SE2->(DbSeek(xFilial("SE2")+Alltrim(cCampo),.T.))
Close(oDlg)
Return

// Substituido pelo assistente de conversao do AP5 IDE em 29/12/99 ==> Function Salir
Static Function Salir()
Close(oDlg)
Return


/*
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ Pago033  ¦ Autor ¦ Leonardo Ruben        ¦ Data ¦ 29.12.99 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Ver o total das facturas selecionadas (p/PRE-Orden de pago)¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Pago030                                                    ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦  DATA    ¦ BOPS ¦                  ALTERACAO                          ¦¦¦
¦¦+----------+------+-----------------------------------------------------¦¦¦
¦¦¦          ¦      ¦                                                     ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Function a085PVSel()
Local n := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cFiltra := ""
SetPrvt("CALIASANT,NORDERANT,ACOLS,AHEADER,NPOSPROV,NSIGNO")
SetPrvt("NDEUDA,OLBX,AROTINA,")

cFiltra:= 'E2_FILIAL=="'+xFilial("SE2")+'"'
cFiltra:= cFiltra +  '.And.E2_FORNECE>="'+mv_par05+'".And.E2_FORNECE<="'+mv_par06+'"'
cFiltra:= cFiltra +  '.And.E2_LOJA>="'+mv_par07+'".And.E2_LOJA<="'+mv_par08+'"'
cFiltra:= cFiltra +  '.And.DTOS(E2_VENCREA)>="'+DtoS(mv_par03)+'".And.DTOS(E2_VENCREA)<="'+DtoS(mv_par04)+'"'
cFiltra:= cFiltra +  ".AND.E2_TIPO $'"+cPagaveis+"'"
cFiltra:= cFiltra +  '.And.E2_SALDO>0'

cAliasAnt := Alias()
nOrderAnt := IndexOrd()

dbSelectArea("SE2")
dbGoTop()
If Eof()
   DbSelectArea(cAliasAnt)
   DbSetOrder(nOrderAnt)
   Return
EndIf

// Hago un listbox para informe de deudas por proveedor
aCols   := {}
aHeader := {}
AADD(aHeader, OemToAnsi(STR0018))  //"Nombre Proveedor"
AADD(aHeader, OemToAnsi(STR0019))  //"Deuda Total ($)"
AADD(aHeader, OemToAnsi(STR0020))  //"PRE-orden ($)"
AADD(aHeader, OemToAnsi(STR0021))  //"Selecci¢n ($)"
AADD(aHeader, OemToAnsi(STR0022))  //"Saldo ($)"
AADD(aHeader, OemToAnsi(STR0023))  //"Prov/Suc"

// Prepara área para localizar proveedores
SA2->( DbSetOrder(1))

// Utiliza indice atual gerado pelo IndRegua
dbSelectArea("SE2")
dbGoTop()
While !Eof()
	If &cFiltra
   		nPosProv := aScan( aCols, {|x| x[6]==AllTrim(E2_FORNECE+E2_LOJA)} )
   		If nPosProv==0
      		SA2->( DbSeek(xFilial("SA2")+SE2->(E2_FORNECE+E2_LOJA)) )
      		Aadd(aCols,{AllTrim(SA2->A2_NOME),0.00,0.00,0.00,0.00,AllTrim(E2_FORNECE+E2_LOJA)})
      		nPosProv := Len( aCols)
   		EndIf

   		nSigno := Iif(Alltrim(SE2->E2_TIPO) $("PA,"+MV_CPNEG),-1,1)
   		nDeuda := (xMoeda(E2_SALDO,E2_moeda,1,dDatabase) * nSigno);
             -xMoeda(SomaAbat(E2_PREFIXO,E2_NUM,E2_PARCELA,"P",E2_MOEDA,dDataBase,E2_FORNECE,E2_LOJA),E2_moeda,1,dDatabase)
   		aCols[nPosProv][2] := aCols[nPosProv][2]+nDeuda

   		If E2_PREOK=="S"
      		aCols[nPosProv][3] := aCols[nPosProv][3]+nDeuda
   		ElseIf IsMark("E2_OK",cMarcaE2)
      		aCols[nPosProv][4] := aCols[nPosProv][4]+nDeuda
   		Else
      		aCols[nPosProv][5] := aCols[nPosProv][5]+nDeuda
   		EndIf
	EndIf
   dbSkip()
End
For n:=1 to len(acols)
	aCols[n][2]:=Transf(aCols[n][2],"@R 999,999,999,999.99")
	aCols[n][3]:=Transf(aCols[n][3],"@R 999,999,999,999.99")
	aCols[n][4]:=Transf(aCols[n][4],"@R 999,999,999,999.99")
	aCols[n][5]:=Transf(aCols[n][5],"@R 999,999,999,999.99")
Next

@ 31,15 TO 200,612 Dialog oDialog Title OemToAnsi(STR0024) //"Saldos por proveedor"
@ 70,271 BMPBUTTON TYPE 01 ACTION Close(oDialog)
If Len(aCols) == 0
	aCols	:=	Array(1,Len(aHeader))
Endif
oLbx := RDListBox( .1, .1, 300, 67, aCols, aHeader)
Activate Dialog oDialog CENTERED

DbSelectArea(cAliasAnt)
DbSetOrder(nOrderAnt)
dbGoTop()

//+-------------------------------------------------------+
//¦ Forçar o array aRotina para dribar a funcao ExecBrow. ¦
//+-------------------------------------------------------+
aRotina[2][4] := 0

// Substituido pelo assistente de conversao do AP5 IDE em 29/12/99 ==> __Return( .F. )
Return( .F. )        // incluido pelo assistente de conversao do AP5 IDE em 29/12/99



/*
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ Pago031  ¦ Autor ¦ Leonardo Ruben        ¦ Data ¦ 27.12.99 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Confirmar/Cancelar PRE-Ordens de pagamentos                ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Pago031                                                    ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦  DATA    ¦ BOPS ¦                  ALTERACAO                          ¦¦¦
¦¦+----------+------+-----------------------------------------------------¦¦¦
¦¦¦          ¦      ¦                                                     ¦¦¦
¦¦¦          ¦      ¦                                                     ¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Function a085PConf( bAcao)
Local lRet := .T.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("CALIASANT,NORDERANT,AROTINA,")

cAliasAnt := Alias()
nOrderAnt := IndexOrd()

If bAcao
   If ExistBlock("Paga085p") .And. !Execblock("Paga085p",.F.,.F.)
      Return .F.
   Endif
   //Cancela facturaS selecionadaS (atribui "S" ao campo E2_PREOK)
   dbSelectArea("SE2")
   dbSetOrder(9)
   dbSeek(xFilial("SE2")+mv_par05+mv_par07,.T.)

	While !Eof() .and. E2_FILIAL  == xFilial("SE2") ;
                 .and. E2_FORNECE <= mv_par06       ;
                 .and. E2_LOJA    <= mv_par08
		If IsMark("E2_OK",cMarcaE2)
			RecLock("SE2",.f.)
			Replace E2_PREOK With "S"
			Replace E2_OK With "  "
			If cPaisLoc <> "BRA"
				Replace E2_VLBXPAR With E2_SALDO
 			EndIf
 			DbUnlock()
      		If ExistBlock("F085E2I")
	      		ExecBlock("F085E2I",.F.,.F.)
			EndIf
		EndIf
      	dbSkip()
	End
   //+-------------------------------------------------------+
   //¦ Forçar o array aRotina para driblar a funcao ExecBrow ¦
   //+-------------------------------------------------------+
   aRotina[3][4] := 0

Else
   // Cancela factura posicionada (limpa campo E2_PREOK)

	dbSelectArea("SE2")

	If ExistBlock("F085PVLD")
		lRet:=ExecBlock("F085PVLD",.F.,.F.,{"I"})
	EndIf
	If lRet
		If E2_PREOK=="S"
			RecLock("SE2",.f.)
			Replace E2_PREOK With " "
			Replace E2_OK With "  "
	        If cPaisLoc <> "BRA" .and. E2_VLBXPAR >0
	        	Replace E2_VLBXPAR With 0
	        EndIf
			DbUnlock()
			If ExistBlock("F085E2E")
		    	ExecBlock("F085E2E",.F.,.F.)
			EndIf
		Else
	    	Help(" ",1,"NOPRE")
		EndIf
	EndIf

Endif

DbSelectArea(cAliasAnt)
DbSetOrder(nOrderAnt)

// Substituido pelo assistente de conversao do AP5 IDE em 29/12/99 ==> __Return( .F. )
Return( .F. )        // incluido pelo assistente de conversao do AP5 IDE em 29/12/99



Function a085BxPar(cAlias,nReg,nOpc)
Local nValbx:=0
Local nOpca := 1
Private oDlg
If E2_PREOK=="S"
	Return
EndIf
//Private lRefresh := .T.
nOpcao:=1
@ 5, 5 TO 350, 650 DIALOG oDlg TITLE OemToAnsi(STR0036) //"Liberacao Parcial"
DbSelectArea(cAlias)
RegtoMemory(cAlias,.F.,.F.)
MsMGet():New(cAlias,SE2->(RecNo()),1,,,STR0036,,{15,10,145,300},,3,,,,,,.T.)
@ 150,010 Say STR0037 //"Informe o valor da Liberacao Parcial"
@ 150,120 Get nValbx Picture(Tm(nValbx,TamSX3("E2_VLBXPAR")[1],MsDecimais(M->E2_MOEDA))) SIZE 80,10
ACTIVATE DIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| nOpca := 1,Confirma(nValbx)},{|| nOpca := 2,Close(oDlg)})
Return

Static Function Confirma(nValBx)
Local lRet:=.F.
If nValbx >0
	If nValbx > E2_SALDO
		mSGsTOP(STR0038,STR0039) //"Valor Liberado nao pode ser maior que o saldo do Titulo"###"Valor"
		lRet:= .F.
	Else
		RecLock("SE2",.f.)
		Replace E2_VLBXPAR With nValbx
		Replace E2_PREOK With "S"
		Replace E2_OK With "  "
		DbUnlock()
		Close(oDlg)
		lRet:= .T.
	EndIf
Else
	MsGStop(STR0037,STR0036) //"Informe o valor da Liberacao Parcial"###"Liberacao Parcial"
	lRet:= .F.
EndIf

Return(lRet)
/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦a085CanPre ¦ Autor ¦ Paulo Augusto         ¦ Data ¦ 13/10/05 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Selecionar varias Pre Ord. de Pago para cancelamento       ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ FINA085P                                                   ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/


Function a085CanPre()

Local oPanel
Local cTexto   := ""

Local cSeek01		:= '"' + xFilial("SE2") + '"'
Local cWhile01	:= ""
Local cFilt		:=""
Local aRet01	:={}

Local aCab		:= {}
Local aLin		:= {}
Local aTam		:= {}
Local aCpo		:= {}
Local lConfirm	:=.F.
Local nPosPref 	:= 0
Local nPosNum 	:= 0
Local nPosParc 	:= 0
Local nPosTip 	:= 0
Local nPosForn 	:= 0
Local nPosLoja 	:= 0
Local nX		:= 0
Local lRet 		:= .T.

Private oOk     := LoadBitMap(GetResources(), "LBTIK")       	// Bitmap utilizado no Lisbox  (Marcado)
Private oNo     := LoadBitMap(GetResources(), "LBNO")			// Bitmap utilizado no Lisbox  (Desmarcado)
Private oNever  := LoadBitMap(GetResources(), "BR_VERMELHO")	// Bitmap utilizado no Lisbox  (Desabilitado / Encerrado)
Private oDlg  ,oLbx

EndFilBrw("SE2",aIndexSE2)
dbSelectArea("SE2")
dbSetOrder(6)

cWhile01	:= '!EOF() .And. E2_FILIAL=="'+ xFilial("SE2") +'"'
cWhile01 := cWhile01 + '.And.E2_FORNECE>="'+mv_par05+'".And.E2_FORNECE<="'+mv_par06+'"'
cWhile01 := cWhile01 + '.And.E2_LOJA>="'+mv_par07+'".And.E2_LOJA<="'+mv_par08+'"'

cFilt:=	" E2_PREOK== 'S'"
cFilt := cFilt + '.And.DTOS(E2_VENCREA)>="'+DtoS(mv_par03)+'".And.DTOS(E2_VENCREA)<="'+DtoS(mv_par04)+'"'
cFilt := cFilt + '.And.E2_TIPO#"CH ".And.E2_TIPO#"TF ".And.Subs(E2_TIPO,3,1)#"-"'
cFilt := cFilt + '.And.E2_SALDO>0'


aRet01	:=LocxGrid("SE2",cWhile01,cFilt,.T.,".F.",cSeek01,1)

aCab	:= AClone(aRet01[3])
aLin	:= AClone(aRet01[5])
aTam	:= AClone(aRet01[4])
aCpo	:= AClone(aRet01[1])


nPosPref := aScan( aCpo, {|x| Upper(Alltrim(x[2]))==Upper(Alltrim("E2_PREFIXO"))} )
nPosNum := aScan( aCpo, {|x| Upper(Alltrim(x[2]))==Upper(Alltrim("E2_NUM"))} )
nPosParc := aScan( aCpo, {|x| Upper(Alltrim(x[2]))==Upper(Alltrim("E2_PARCELA"))} )
nPosTip := aScan( aCpo, {|x| Upper(Alltrim(x[2]))==Upper(Alltrim("E2_TIPO"))} )
nPosForn := aScan( aCpo, {|x| Upper(Alltrim(x[2]))==Upper(Alltrim("E2_FORNECE"))} )
nPosLoja := aScan( aCpo, {|x| Upper(Alltrim(x[2]))==Upper(Alltrim("E2_LOJA"))} )




@ 5, 5 TO 350, 700 DIALOG oDlg TITLE OemToAnsi(STR0041) //"Selecionar Pre-Ordem

oLbx:=TwBrowse():New(000,000,350,150,,aCab,aTam,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oLbx:lColDrag	:= .T.
oLbx:nFreeze	:= 1
oLbx:bLDblClick	:={ || ChgMarkLb(@oLbx,@aLin,{||.T.},.T.) }
oLbx:SetArray(aLin)
oLbx:bLine		:= LocxBlin("oLbx",aCpo,.T.)
@ 155,270 BMPBUTTON TYPE 1 ACTION (lConfirm:=.T.,Close(oDlg))
@ 155,310 BMPBUTTON TYPE 2 ACTION (Close(oDlg))

Activate MsDialog oDlg Centered

If lConfirm

	For nX:=1 To Len(aLin)
		If aLin[nX][1] >0
			dbSelectArea("SE2")
			dbSetOrder(1)
			Dbseek(xFilial("SE2")+ aLin[nX][nPosPref]+aLin[nX][nPosNum]+aLin[nX][nPosParc]+;
			aLin[nX][nPosTip]+aLin[nX][nPosForn]+aLin[nX][nPosLoja])
			If ExistBlock("F085PVLD")
				lRet:=ExecBlock("F085PVLD",.F.,.F.,{"M"})
			EndIf
			If lRet
				RecLock("SE2",.f.)
				Replace E2_PREOK With " "
				Replace E2_OK With "  "
		  		If cPaisLoc <> "BRA" .and. E2_VLBXPAR >0
		   			Replace E2_VLBXPAR With 0
		 		EndIf
				DbUnlock()
			EndIf
		EndIf
	Next
EndIf
Eval(bFiltraBrw)
Return()



Static Function MenuDef()
Local aRotina := {}

If cPaisLoc <> "BRA"
		aRotina := { { OemToAnsi(STR0014),'PesqBrw'   ,0 ,1},;  //"Buscar"
	              { OemToAnsi(STR0015),'a085PVSel()'   ,0 ,3},;  //"Ver Selecci¢n"
	              { OemToAnsi(STR0016),'a085PConf(.t.)',0 ,3},;  //"Confirmar"
	              { OemToAnsi(STR0035),'a085BxPar',0 ,3},;    //"Parcial"
	              { OemToAnsi(STR0040),'a085CanPre',0 ,3},;    // "Desfazer Mult."
	              { OemToAnsi(STR0017),'a085PConf(.f.)',0 ,3} }  //"Deshacer"
	Else
		aRotina := { { OemToAnsi(STR0014),'PesqBrw'   ,0 ,1},;  //"Buscar"
	              { OemToAnsi(STR0015),'a085PVSel()'   ,0 ,3},;  //"Ver Selecci¢n"
	              { OemToAnsi(STR0016),'a085PConf(.t.)',0 ,3},;  //"Confirmar"
   	              { OemToAnsi(STR0040),'a085CanPre',0 ,3},;    // "Desfazer Mult."
	              { OemToAnsi(STR0017),'a085PConf(.f.)',0 ,3} }  //"Deshacer"
	EndIf
Return(aRotina)
