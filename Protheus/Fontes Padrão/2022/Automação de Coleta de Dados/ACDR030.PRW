#INCLUDE "ACDR030.ch" 
#INCLUDE "Protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAcdR030   บ Autor ณ ACD                บ Data ณ  11/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relacao de Inventario de Estoque (ACD)                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ACDA030                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/   
Function AcdR030()
Local lModelo1  := SuperGetMv("MV_CBINVMD")=="1"

Private nTamCod  := Min(TamSX3("CBA_PROD")[1],30) + 1
Private nTamDesc := Min(TamSX3("B1_DESC")[1],60) + 2
Private cPicSB2  := X3Picture("B2_QATU")
Private nTamTot  := nTamCod + nTamDesc

If lModelo1
	ACDR30A()
Else
	ACDR30B()
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ACDR030A บ Autor ณErike Yuri da Silvaบ Data ณ  04/01/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio do Monitoramento de Inventario Modelo 1 para    บฑฑ
ฑฑบ          ณ codigo interno.                                           บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ACDSTDIN                                        			 บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/ 
Function ACDR30A()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local lUsaCB001 := UsaCB0("01")

Private cString      := "CBA"
Private aOrd         := {}
Private cDesc1       := STR0001 //"Este programa tem como objetivo imprimir informacoes referentes ao "
Private cDesc2       := STR0002 //"monitoramento do inventario do ACD"
Private cDesc3       := STR0003+If(lUsaCB001,STR0004,STR0005)+STR0006 //"usando codigo "###"interno"###"natural"###" modelo 1"
Private cPict        := ""
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 220
Private tamanho      := "G"
Private nomeprog     := "ACDR030A" 
Private nTipo        := 18
Private aReturn      := {STR0007,1,STR0008, 2, 2, 1, "", 1}  //"Zebrado"###"Administracao"
Private nLastKey     := 0
Private cPerg        := "AIA037"
Private titulo       := STR0009+; //"Relatorio de Monitoramento do Inventario para Codigo "
                         If(lUsaCB001,STR0004,STR0005)+STR0006 //"Interno"###"Natural"###" Modelo 1"
Private nLin         := 99
Private Cabec1       := ""
Private Cabec2       := ""
Private cbtxt        := STR0010 //"Registro(s) lido(s)"
Private cbcont       := 0
Private CONTFL       := 01
Private m_pag        := 01
Private imprime      := .T.
Private wnrel        := "ACDR030A"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis utilizadas como Parametros                                ณ
//ณ MV_PAR01 = Mestre De          ?                                     ณ
//ณ MV_PAR02 = Mestre Ate         ?                                     ณ
//ณ MV_PAR03 = Armazem De         ?                                     ณ
//ณ MV_PAR04 = Armazem Ate        ?                                     ณ
//ณ MV_PAR05 = Produto De         ?                                     ณ
//ณ MV_PAR06 = Produto Ate        ?                                     ณ
//ณ MV_PAR07 = Endereco De        ?                                     ณ
//ณ MV_PAR08 = Endereco Ate       ?                                     ณ
//ณ MV_PAR09 = Data De            ?                                     ณ
//ณ MV_PAR10 = Data Ate           ?                                     ณ
//ณ MV_PAR11 = Status             ?                                     ณ
//ณ MV_PAR12 = Tipo de Inventario ?                                     ณ
//ณ MV_PAR13 = Lista Etiquetas    ?                                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,Nil,.T.)

Pergunte(cPerg,.F.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

Processa({|| R030A() },Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ R030A     บ Autor ณERIKE YURI DA SILVAบ Data ณ  30/08/04   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ACDR030                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis utilizadas como Parametros                                ณ
//ณ MV_PAR01 = Mestre De          ?                                     ณ
//ณ MV_PAR02 = Mestre Ate         ?                                     ณ
//ณ MV_PAR03 = Armazem De         ?                                     ณ
//ณ MV_PAR04 = Armazem Ate        ?                                     ณ
//ณ MV_PAR05 = Produto  De        ?                                     ณ
//ณ MV_PAR06 = Produto  Ate       ?                                     ณ
//ณ MV_PAR07 = Endereco De        ?                                     ณ
//ณ MV_PAR08 = Endereco Ate       ?                                     ณ
//ณ MV_PAR09 = Data De            ?                                     ณ
//ณ MV_PAR10 = Data Ate           ?                                     ณ
//ณ MV_PAR11 = Status             ?                                     ณ
//ณ MV_PAR12 = Tipo de Inventario ?                                     ณ
//ณ MV_PAR13 = Lista Etiquetas    ?                                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
/*/
Static Function R030A()
Local cExpres    := ""
Local cIndCBA    := ""
Local cIndex     := ""
Local cMestreDe  := MV_PAR01
Local cMestreAte := MV_PAR02
Local cArmDe     := MV_PAR03
Local cArmAte    := MV_PAR04
Local cProdDe    := MV_PAR05
Local cProdAte   := MV_PAR06
Local cEndDe     := MV_PAR07
Local cEndAte    := MV_PAR08
Local dDtDe      := MV_PAR09
Local dDtAte     := MV_PAR10
Local nStatusInv := MV_PAR11
Local cTipoInv   := Str(MV_PAR12,1)
Local cTipoInvAtu:= ""
Local lPrintEtiq := If(MV_PAR13==1,.T.,.F.)
Local nIndex     := 0
Local nPos       := 0
Local cCodInv    := ""
Local cStatus    := ""
Local lFirst     := .t.
Local lLocaliza  := .f. //Controle de localizacao
Local lMV_LOCALIZ:= SuperGetMV("MV_LOCALIZ",.F.,"N")=="S"
Local lWmsNew    := SuperGetMv("MV_WMSNEW",.F.,.F.)
Local aAreaCBA   := CBA->(GetArea())
Local aProdLido  := {}
Local aEtiqLida  := {}
Local aRetCBB    := {}
Local aRetSld    := {}
Local ni
Private cCodOpe  := ""
Private cCBBNum  := ""
Private cClasses :=""
Private nContagem:= 0
Private lUsaCB001:= UsaCB0("01")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta filtro e indice da IndRegua                            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
SB1->(DbSetorder(1))
SBF->(DbSetorder(1))
SB3->(DbSetOrder(1))
CBC->(DbSetOrder(3))
CBB->(DbSetOrder(1))
CBA->(DbSetOrder(1))

cIndex	:= IndexKey()

cExpres	:= 'CBA_FILIAL=="'		+xFilial("CBA")	+'".And.'
cExpres	+= 'CBA_CODINV>="'		+cMestreDe	+'".And.'
cExpres	+= 'CBA_CODINV<="'		+cMestreAte	+'".And.'
cExpres	+= 'CBA_LOCAL>="'		+cArmDe		+'".And.'
cExpres	+= 'CBA_LOCAL<="'		+cArmAte	+'".And.'
cExpres	+= 'CBA_PROD>="'		+cProdDe	+'".And.'
cExpres	+= 'CBA_PROD<="'		+cProdAte	+'".And.'
If lMV_LOCALIZ
	cExpres+= 'CBA_LOCALI>="'	+cEndDe		+'".And.'
	cExpres+= 'CBA_LOCALI<="'	+cEndAte	+'".And.'
EndIf
cExpres+= 'DTOS(CBA_DATA)>="'+DTOS(dDtDe)	+'".And.'
cExpres+= 'DTOS(CBA_DATA)<="'+DTOS(dDtAte)	+'"'
If cTipoInv $ "1|2"
	cExpres+= '.And. CBA_TIPINV=="'+cTipoInv+'"'
EndIf

cIndCBA := CriaTrab(Nil,.F.)
IndRegua("CBA",cIndCBA,cIndex,Nil,cExpres,STR0012) //"Selecionando Registros ..."
nIndex := RetIndex("CBA")
dbSetOrder(nIndex+1)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica o numero de registros validos para a SetRegua ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
CBA->(DbGoTop())
CBA->(ProcRegua(RecCount()))

cCodInv := CBA->CBA_CODINV
While !CBA->(Eof())
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Verifica se o usuario interrompeu o relatorio                ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If	lAbortPrint
		@nLin,00 PSAY STR0013 //"*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	IncProc(STR0014+CBA->CBA_CODINV)    //"Processando Mestre de Inventario: "
	If	(nStatusInv != 5)
		If	(nStatusInv == 1 .AND. !(CBA->CBA_STATUS $ "12")) .OR. ;
			(nStatusInv == 2 .AND. CBA->CBA_STATUS != "3")    .OR. ;
			(nStatusInv == 3 .AND. CBA->CBA_STATUS != "4")    .OR. ;
			(nStatusInv == 4 .AND. CBA->CBA_STATUS != "5")    .OR. (CBA->CBA_STATUS == "0")
			cCodInv := CBA->CBA_CODINV
			CBA->(DbSkip())
		Loop
		EndIf
	Endif

	cCBBNum  := ""
	cCodOpe  := ""
	nContagem:= 0
	cStatus  := ""
	CBB->(DbSeek(xFilial("CBB")+CBA->CBA_CODINV))
	While CBB->(!Eof() .AND. CBB_FILIAL+CBB_CODINV == xFilial("CBA")+CBA->CBA_CODINV)
		nContagem++
		cCBBNum  := CBB->CBB_NUM
		cCodOpe  := CBB->CBB_USU
		cStatus  := CBB->CBB_STATUS	
		If cStatus=="1"
			Exit
		EndIf
		CBB->(DbSkip())
	Enddo

	If lFirst .AND. cTipoInv != "3"
		ImpCabec(cStatus)
		lFirst := .f.
	Endif

	If cStatus == "1" // Em andamento
		If nLin > 59 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
			ImpCabec(cStatus)
		Endif
		ImpCbcDet1(.f.,(cCodInv <> CBA->CBA_CODINV))
		nLin++
		@nLin, 000 PSAY '*** A CONTAGEM "'+cCBBNUM+'" ESTA EM ANDAMENTO  -  '+TIME()+'   ***'
		nLin++
		cCodInv := CBA->CBA_CODINV
		CBA->(DbSkip())
		Loop
	ElseIf Empty(nContagem)
		If nLin > 59 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
			ImpCabec(cStatus)
		Endif
		ImpCbcDet1(.f.,(cCodInv <> CBA->CBA_CODINV))
		nLin++
		@nLin, 000 PSAY '*** NAO EXISTE CONTAGEM PARA ESTE MESTRE DE INVENTARIO  -  '+TIME()+'   ***'       
		nLin++
		cCodInv := CBA->CBA_CODINV
		CBA->(DbSkip())
		Loop
	ElseIf (cTipoInv == "3") .AND. !Empty(cTipoInvAtu) .AND. CBA->CBA_TIPINV # cTipoInvAtu 
		cTipoInvAtu := CBA->CBA_TIPINV
		ImpCabec(cStatus)
		ImpCbcDet1(.t.,.f.)
	Else
		If nLin > 59 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
			ImpCabec(cStatus)
		Endif
		ImpCbcDet1(.t.,(cCodInv <> CBA->CBA_CODINV))
	EndIf
	aProdLido := {}
	CBC->(DbSetOrder(3))
	CBC->(DbSeek(xFilial("CBC")+CBA->CBA_CODINV))
	While CBC->(!Eof() .AND. CBC_FILIAL+CBC_CODINV == xFilial("CBB")+CBA->CBA_CODINV)
		nPos := AsCan(aProdLido,{|x| x[1]+x[3]+x[4]+x[5]+x[6]+x[7]==CBC->(CBC_COD+CBC_LOCAL+CBC_LOCALI+CBC_LOTECT+CBC_NUMLOT+CBC_NUMSER)})
		If !Empty(nPos)
		CBC->(DbSkip())
			Loop
		EndIf
		SB1->(DbSeek(xFilial('SB1')+CBC->CBC_COD))
		SB3->(DbSeek(xFilial('SB3')+CBC->CBC_COD))

		If lMV_LOCALIZ .and. Localiza(CBC->CBC_COD,.T.)
			lLocaliza := .t.
		Else
			lLocaliza := .f.
		EndIf

		CBC->(Aadd(aProdLido,{CBC_COD,Left(SB1->B1_DESC,nTamDesc-2),CBC_LOCAL,CBC_LOCALI,;
									CBC_LOTECT,CBC_NUMLOT,CBC_NUMSER,SB3->B3_CLASSE,0,0}))
		If lLocaliza
			// Verifica novo WMS e produto ้ controlado
			If !(lWmsNew .And. IntWms(CBC->CBC_COD))
				aProdLido[Len(aProdLido),9] := CBC->(SaldoSBF(CBC_LOCAL,CBC_LOCALI,CBC_COD,CBC_NUMSER,CBC_LOTECT,CBC_NUMLOT))
			Else  
				aProdLido[Len(aProdLido),9] := CBC->(WmsSldD14(CBC_LOCAL,CBC_LOCALI,CBC_COD,CBC_NUMSER,CBC_LOTECT,CBC_NUMLOT))
			EndIf
		Else
			SB2->(DbSeek(xFilial('SB2')+CBC->(CBC_COD+CBC_LOCAL)))
			aProdLido[Len(aProdLido),9] :=	SaldoSB2(,.F.)
		EndIf
		CBC->(DbSkip())
	Enddo

	aRetCBB   := RetInfoCBB()	
	aEtiqLida := Array(Len(aprodLido))
	For nI:=1 To Len(aProdLido)
		aRetSld          := ElegEti(aProdLido[nI,1]+aProdLido[nI,3]+aProdLido[nI,4]+aProdLido[nI,5]+ ;
                                  aProdLido[nI,6]+aProdLido[nI,7],aRetCBB)
		aProdLido[nI,10] := aRetSld[1]
		aEtiqLida[nI]    := aRetSld[3]
	Next

	//Imprimir 
	//Possicoes do array aProdLido
	//[01] - CBC->CBC_COD
	//[02] - Left(SB1->B1_DESC,30)
	//[03] - CBC->CBC_LOCAL
	//[04] - CBC->CBC_LOCALI
	//[05] - CBC->CBC_LOTECT
	//[06] - CBC->CBC_NUMLOT
	//[07] - CBC->CBC_NUMSER
	//[08] - SB3->B3_CLASSE
	//[09] - SALDO EM ESTOQUE
	//[10] - QTD. ELEITA
	For nI:=1 To Len(aProdLido)
		If nLin > 59 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
			ImpCabec(cStatus)
		Endif
		If lUsaCB001 .and.  lPrintEtiq    
			ImpCbcDet4(nI,aProdLido)
			While .T.
				If nLin > 59 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
					ImpCabec(cStatus)
				Endif

				nPos := AsCan(aEtiqLida[nI],{|x| x[3]==aProdLido[nI,1]+aProdLido[nI,3]+aProdLido[nI,4]+aProdLido[nI,5]+aProdLido[nI,6]+aProdLido[nI,7]})
				If nPos > 0
					@nLin,016 PSAY aEtiqLida[nI][nPos,1]
					@nLin,034 PSAY aEtiqLida[nI][nPos,2] Picture cPicSB2
					nLin++
					aDel(aEtiqLida[nI],nPos)
					aSize(aEtiqLida[nI],Len(aEtiqLida[nI])-1)
					Loop
				EndIf
				Exit
			EndDo
			nLin+=2
		Else
			ImpCbcDet3(nI,aProdLido)
		EndIf
	Next
	cCodInv := CBA->CBA_CODINV
	CBA->(DbSkip())
EndDo

If nLin # 06
	@nLin,000 PSAY ""
Endif

dbSelectArea("CBA")
RetIndex("CBA")
Ferase(cIndCBA+OrdBagExt())
dbClearFilter()

SET DEVICE TO SCREEN
If aReturn[5]==1
	DbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif
MS_FLUSH()
RestArea(aAreaCBA)
Return

//--------------------------------


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฺฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฟ
ณFuncaoณRetInfoCBB()        ณAutorณErike Yuri da Silvaณ17/07/04ณ
รฤฤฤฤฤฤมฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤด
ณDescricao ณCarrega informacoes da tabela CBB em um array      ณ
รฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด
ณRetorno:  ณ Array com os numeros de contagem,usuario e status ณ
ณ          ณ da tabela CBB.                                    ณ
ภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function RetInfoCBB()
Local aRet := {}
	CBC->(dbSetOrder(2))
	CBB->(dbSetOrder(3))
	CBB->(DbSeek(xFilial('CBB')+CBA->CBA_CODINV))
	While CBB->(!EOF() .AND. CBB_FILIAL+CBB_CODINV==xFilial('CBB')+CBA->CBA_CODINV)
		If !CBC->(DbSeek(xFilial("CBC")+CBB->CBB_NUM))
			CBB->(DbSkip())
			Loop
		EndIf
		Aadd(aRet,{CBB->CBB_NUM,CBB->CBB_USU,CBB->CBB_STATUS})
		CBB->(DbSkip())
	EndDo
Return aClone(aRet)


Static Function ElegEti(cChave,aRetCBB)
Local cProduto,cArm,cEnd,cLote,cSLote,cNumSeri
Local cCodCBB   := CBB->CBB_NUM
Local cAux      :=''
Local nSaldo
Local nPos
Local i, j
Local aProds    := {}
Local aProdAux  := {}
Local aProdOK   := {}
Local aProdOK2  := {}
Local aProdNoOk :={}
Local aEtiQtdOK :={}
Local aEtiLidas :={}
Local nTamCB0   := TamSX3("CB0_CODETI")[1]

Private aCods 	:= {}

For i:=1 To Len(aRetCBB)
	If aRetCBB[i,3] == "2"
		Aadd(aCods,aRetCBB[i,1])
	EndIf
Next

CBC->(dbSetOrder(2))
For i := 1 To Len(aCods)
	CBC->(dbSeek(xFilial('CBC')+aCods[i]+cChave))
	While CBC->(!Eof().and. CBC_FILIAL+CBC->CBC_NUM+CBC_COD+CBC_LOCAL+CBC_LOCALI+CBC_LOTECT+CBC_NUMLOT+CBC_NUMSER==xFilial("CBC")+aCods[i]+cChave)
		cAux:=Space(10)
		If lUsaCB001 .and. CBProdUnit(CBC->CBC_COD)
			cAux:= CBC->CBC_CODETI
		EndIf
		If lUsaCB001
			If Ascan(aEtiLidas,CBC->CBC_CODETI) == 0
				aadd(aEtiLidas,CBC->CBC_CODETI)
			EndIf
		EndIf
		nPos := Ascan(aProds,{|x| x[1] == CBC->(CBC_COD+CBC_LOCAL+CBC_LOCALI+CBC_LOTECT+CBC_NUMLOT+CBC_NUMSER+cAux) .and. x[3]==CBC->CBC_NUM })	
		If nPos > 0
			aProds[nPos,2] +=  CBC->CBC_QUANT
		Else
			Aadd(aProds,{CBC->( CBC_COD+CBC_LOCAL+CBC_LOCALI+CBC_LOTECT+CBC_NUMLOT+CBC_NUMSER+cAux),CBC->CBC_QUANT,CBC->CBC_NUM})
		Endif
		CBC->(dbSkip())
	EndDo
Next i
For i := 1 to len(aProds)
	For j:= 1 to len(aCods)
		CBC->(dbSetOrder(2))
		If ! CBC->(DBSeek(xFilial("CBC")+aCods[j]+aProds[i,1]))
			If Ascan(aProds,{|x| x[1] == aProds[i,1] .and. x[2] ==0 .and. x[3] == aCods[j]  }) == 0
				Aadd(aProds,{aProds[i,1],0,aCods[j]})
			EndIf
		EndIf
	Next
Next
For i := 1 to len(aProds)
	nPos := Ascan(aProdAux,{|x| Padr(x[1],78)==Padr(aProds[i,1],78) .and. StrZero(x[2],12,4) == StrZero(aProds[i,2],12,4) })
	If nPos==0
		Aadd(aProdAux,{aProds[i,1],aProds[i,2],1})
	Else
		aProdAux[nPos,3]++
	EndIf
Next
For i := 1 to len(aProdAux)
	If aProdAux[i,3] >= CBA->CBA_CONTS
		nPos := Ascan(aProdOK,{|x| x[1] == aProdAux[i,1]})
		If nPos== 0
			aadd(aProdOk,{aProdAux[i,1],aProdAux[i,2]})
			If Subs(aProdAux[i,1],Len(aProdAux[i,1])-(nTamCB0-1),10) <> Space(nTamCB0) 
				aadd(aEtiQtdOK,{Subs(aProdAux[i,1],Len(aProdAux[i,1])-(nTamCB0-1),10),aProdAux[i,2],Subs(aProdAux[i,1],1,Len(aProdAux[i,1])-(nTamCB0))})
			EndIf
		EndIf
	Else
		nPos := Ascan(aProdNoOK,{|x| x[1] == aProdAux[i,1]})
		If nPos == 0
			aadd(aProdNoOK,{aProdAux[i,1]})
		EndIf
	EndIf
Next
nSaldo := 0
For i := 1 to len(aProdOk)
	nPos := Ascan(aProdNoOK,{|x| x[1] == aProdOK[i,1]})
	If nPos > 0
		aDel(aProdNoOk,nPos)
		aSize(aPRodNoOk,Len(aProdNoOK)-1)
	EndIf
	nSaldo += aProdOk[i,2]
Next
Return {nSaldo,(len(aProdNoOK) == 0),aEtiQtdOk}


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ACDR030B บ Autor ณErike Yuri da Silvaบ Data ณ  04/01/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio do Monitoramento de Inventario Modelo 1 para    บฑฑ
ฑฑบ          ณ codigo interno.                                           บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ACDSTDIN                                        			 บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function ACDR30B()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local lUsaCB001		:= UsaCB0("01")

Private cString		:= "CBA"
Private aOrd         := {}
Private cDesc1       := STR0001 //"Este programa tem como objetivo imprimir informacoes referentes ao "
Private cDesc2       := STR0002 //"monitoramento do inventario do ACD"
Private cDesc3       := STR0003+If(lUsaCB001,STR0004,STR0005)+STR0017 //"usando codigo "###"interno"###"natural"###" modelo 2"
Private cPict        := ""
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 220
Private tamanho      := "G"
Private nomeprog     := "ACDR030B"
Private nTipo        := 18
Private aReturn      := {STR0007,1,STR0008, 2, 2, 1, "", 1}  //"Zebrado"###"Administracao"
Private nLastKey     := 0
Private cPerg        := "AIA037"
Private titulo       := STR0009+; //"Relatorio de Monitoramento do Inventario para Codigo "
                         If(lUsaCB001,STR0004,STR0005)+STR0017 //"Interno"###"Natural"###" Modelo 2"
Private nLin         := 99
Private Cabec1       := ""
Private Cabec2       := ""
Private cbtxt        := STR0010 //"Registro(s) lido(s)"
Private cbcont       := 0
Private CONTFL       := 01
Private m_pag        := 01
Private imprime      := .T.
Private wnrel        := "ACDR030B"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis utilizadas como Parametros                                ณ
//ณ MV_PAR01 = Mestre De          ?                                     ณ
//ณ MV_PAR02 = Mestre Ate         ?                                     ณ
//ณ MV_PAR03 = Armazem De         ?                                     ณ
//ณ MV_PAR04 = Armazem Ate        ?                                     ณ
//ณ MV_PAR05 = Produto  De        ?                                     ณ
//ณ MV_PAR06 = Produto  Ate       ?                                     ณ
//ณ MV_PAR07 = Endereco De        ?                                     ณ
//ณ MV_PAR08 = Endereco Ate       ?                                     ณ
//ณ MV_PAR09 = Data De            ?                                     ณ
//ณ MV_PAR10 = Data Ate           ?                                     ณ
//ณ MV_PAR11 = Status             ?                                     ณ
//ณ MV_PAR12 = Tipo de Inventario ?                                     ณ
//ณ MV_PAR13 = Lista Etiquetas    ?                                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,Nil,.T.)

Pergunte(cPerg,.F.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

Processa({|| R030B() },Titulo)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ R030B     บ Autor ณErike Yuri da Silvaบ Data ณ  11/02/05   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ACDR030B                                        			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis utilizadas como Parametros                                ณ
//ณ MV_PAR01 = Mestre De          ?                                     ณ
//ณ MV_PAR02 = Mestre Ate         ?                                     ณ
//ณ MV_PAR03 = Armazem De         ?                                     ณ
//ณ MV_PAR04 = Armazem Ate        ?                                     ณ
//ณ MV_PAR05 = Produto  De        ?                                     ณ
//ณ MV_PAR06 = Produto  Ate       ?                                     ณ
//ณ MV_PAR07 = Endereco De        ?                                     ณ
//ณ MV_PAR08 = Endereco Ate       ?                                     ณ
//ณ MV_PAR09 = Data De            ?                                     ณ
//ณ MV_PAR10 = Data Ate           ?                                     ณ
//ณ MV_PAR11 = Status             ?                                     ณ
//ณ MV_PAR12 = Tipo de Inventario ?                                     ณ
//ณ MV_PAR13 = Lista Etiquetas    ?                                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
/*/
Static Function R030B()
Local cExpres
Local cIndCBA
Local cIndex
Local cMestreDe  := MV_PAR01
Local cMestreAte := MV_PAR02
Local cArmDe     := MV_PAR03
Local cArmAte    := MV_PAR04
Local cProdDe    := MV_PAR05
Local cProdAte   := MV_PAR06
Local cEndDe     := MV_PAR07
Local cEndAte    := MV_PAR08
Local dDtDe      := MV_PAR09
Local dDtAte     := MV_PAR10
Local nStatusInv := MV_PAR11
Local cTipoInv	  := Str(MV_PAR12,1)
Local lPrintEtiq := If(MV_PAR13==1,.T.,.F.)
Local nIndex     := 0
Local nPos		  := 0
Local cCodInv    := ""
Local cStatus    := ""
Local cProdAtu	  := ""
Local lFirst     := .t.
Local lLocaliza  := .f. 	//Controle de localizacao
Local lUsaCB001  := UsaCB0("01")
Local lMV_LOCALIZ:= SuperGetMV("MV_LOCALIZ",.F.,"N")=="S"
Local lWmsNew    := SuperGetMv("MV_WMSNEW",.F.,.F.)
Local aAreaCBA   := CBA->(GetArea())
Local aProdLido  := {}
Local aEtiqLida  := {}
Local nI
Private cCodOpe  := ""
Private cCBBNum  := ""
Private cClasses :=""
Private nContagem:= 0

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta filtro e indice da IndRegua                            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

SB1->(DbSetorder(1))
SBF->(DbSetorder(1))
SB3->(DbSetOrder(1))
CBC->(DbSetOrder(2))
CBB->(DbSetOrder(1))
CBA->(DbSetOrder(1))

cIndex:= IndexKey()

cExpres:= 'CBA_FILIAL=="'+xFilial("CBA")+'".And.'
cExpres+= 'CBA_CODINV>="'+cMestreDe+'".And.'
cExpres+= 'CBA_CODINV<="'+cMestreAte+'".And.'
cExpres+= 'CBA_LOCAL>="'+cArmDe+'".And.'
cExpres+= 'CBA_LOCAL<="'+cArmAte+'".And.'
cExpres+= 'CBA_PROD>="'+cProdDe+'".And.'
cExpres+= 'CBA_PROD<="'+cProdAte+'".And.'
cExpres+= 'CBA_LOCALI>="'+cEndDe+'".And.'
cExpres+= 'CBA_LOCALI<="'+cEndAte+'".And.'
cExpres+= 'DTOS(CBA_DATA)>="'+DTOS(dDtDe)+'".And.'
cExpres+= 'DTOS(CBA_DATA)<="'+DTOS(dDtAte)+'"'
If cTipoInv $ "1|2"
	cExpres+= '.And. CBA_TIPINV=="'+cTipoInv+'"'
EndIf

cIndCBA := CriaTrab(Nil,.F.)

IndRegua("CBA",cIndCBA,cIndex,Nil,cExpres,STR0012) //"Selecionando Registros ..."
nIndex := RetIndex("CBA")

dbSetOrder(nIndex+1)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica o numero de registros validos para a SetRegua ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
CBA->(DbGoTop())
CBA->(ProcRegua(RecCount()))

cCodInv := CBA->CBA_CODINV
While !CBA->(Eof())
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Verifica se o usuario interrompeu o relatorio                ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lAbortPrint
		@nLin,00 PSAY STR0013 //"*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	IncProc(STR0014+CBA->CBA_CODINV)    //"Processando Mestre de Inventario: "
	If (nStatusInv != 5)
		If	(nStatusInv == 1 .AND. !(CBA->CBA_STATUS $ "12")) .OR. ;
			(nStatusInv == 2 .AND. CBA->CBA_STATUS != "3") 	.OR.;
			(nStatusInv == 3 .AND. CBA->CBA_STATUS != "4")    .OR.;
			(nStatusInv == 4 .AND. CBA->CBA_STATUS != "5") .OR. (CBA->CBA_STATUS == "0")
			cCodInv := CBA->CBA_CODINV
			CBA->(DbSkip())
		Loop
		EndIf
	Endif
	
	cCBBNum  := ""
	cCodOpe  := ""
	cStatus  := ""
	nContagem:= 0
	CBB->(DbSeek(xFilial("CBB")+CBA->CBA_CODINV))
	While CBB->(!Eof() .AND. CBB_FILIAL+CBB_CODINV == xFilial("CBA")+CBA->CBA_CODINV)
		nContagem++
		cCBBNum  := CBB->CBB_NUM
		cCodOpe  := CBB->CBB_USU
		cStatus  := CBB->CBB_STATUS
		CBB->(DbSkip())
	Enddo
	If lFirst .AND. cTipoInv != "3"
		ImpCabec(cStatus)
		lFirst := .f.
	Endif

	If cStatus == "1" // Em andamento
		If nLin > 59 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
			ImpCabec(cStatus)
		Endif
		ImpCbcDet1(.f.,(cCodInv <> CBA->CBA_CODINV))
		nLin++
		@nLin, 000 PSAY STR0019+TIME()+"   ***"        //"***  CONTAGEM EM ANDAMENTO  -  "
		nLin++
		cCodInv := CBA->CBA_CODINV
		CBA->(DbSkip())
		Loop
	ElseIf (cTipoInv == "3") .and. (CBA->CBA_TIPINV # cTipoInv) .AND. CBC->(DbSeek(xFilial("CBC")+cCBBNum))
		cTipoInv := CBA->CBA_TIPINV
		ImpCabec(cStatus)
		ImpCbcDet1(.t.,.f.)
	ElseIf CBC->(DbSeek(xFilial("CBC")+cCBBNum))
		If nLin > 59 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
			ImpCabec(cStatus)
		Endif
		ImpCbcDet1(.t.,(cCodInv <> CBA->CBA_CODINV))
	Else
		If nLin > 59 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
			ImpCabec(cStatus)
		Endif
		ImpCbcDet1(.f.,(cCodInv <> CBA->CBA_CODINV))
		nLin++
		@nLin, 000 PSAY STR0020+cCBBNum+STR0021        //"***  ITENS DO INVENTARIO "###" NAO ENCONTRADOS ***"
		nLin++
		cCodInv := CBA->CBA_CODINV
		CBA->(DbSkip())
		Loop
	Endif

	aProdLido := {}
	aEtiqLida := {}
	CBC->(DbSetOrder(2))
	CBC->(DbSeek(xFilial("CBC")+cCBBNum))
	While CBC->(!Eof() .AND. CBC_FILIAL+CBC_NUM == xFilial("CBB")+cCBBNum)
		nPos := AsCan(aProdLido,{|x| x[1]+x[3]+x[4]+x[5]+x[6]+x[7]==CBC->(CBC_COD+CBC_LOCAL+CBC_LOCALI+CBC_LOTECT+CBC_NUMLOT+CBC_NUMSER)})
		If Empty(nPos)
			SB1->(DbSeek(xFilial('SB1')+CBC->CBC_COD))
			SB3->(DbSeek(xFilial('SB3')+CBC->CBC_COD))

			If lMV_LOCALIZ .and. Localiza(CBC->CBC_COD,.T.)
				lLocaliza := .t.
			Else
				lLocaliza := .f.
			EndIf

			CBC->(Aadd(aProdLido,{CBC_COD,Left(SB1->B1_DESC,nTamDesc-2),CBC_LOCAL,CBC_LOCALI,;
		    								CBC_LOTECT,CBC_NUMLOT,CBC_NUMSER,SB3->B3_CLASSE,0,CBC->CBC_QUANT}))

			If lLocaliza
				// Verifica novo WMS e produto ้ controlado
				If !(lWmsNew .And. IntWms(CBC->CBC_COD))
					aProdLido[Len(aProdLido),9] := CBC->(SaldoSBF(CBC_LOCAL,CBC_LOCALI,CBC_COD,CBC_NUMSER,CBC_LOTECT,CBC_NUMLOT))
				Else  
					aProdLido[Len(aProdLido),9] := CBC->(WmsSldD14(CBC_LOCAL,CBC_LOCALI,CBC_COD,CBC_NUMSER,CBC_LOTECT,CBC_NUMLOT))
				EndIf
			Else
				If Rastro(CBC->CBC_COD) 
					aProdLido[Len(aProdLido),9] := SaldoLote(CBC->CBC_COD,CBC->CBC_LOCAL,CBC->CBC_LOTECT,CBC->CBC_NUMLOT, Nil, Nil, Nil,dDataBase)
				Else
					SB2->(DbSeek(xFilial('SB2')+CBC->(CBC_COD+CBC_LOCAL)))
					aProdLido[Len(aProdLido),9] :=	SaldoSB2(,.F.)
				EndIF
			EndIf

		Else
			aProdLido[nPos,10] += CBC->CBC_QUANT
		EndIf
		If lUsaCB001 .AND. lPrintEtiq
			CBC->(Aadd(aEtiqLida,{CBC_COD,CBC_LOCAL,CBC_LOCALI,	CBC_LOTECT,CBC_NUMLOT,CBC_NUMSER,CBC_CODETI,CBC_QUANT}))
		EndIf

		CBC->(DbSkip())
	Enddo
	//Imprimir
	//Possicoes do array aProdLido
	//[01] - CBC->CBC_COD
	//[02] - Left(SB1->B1_DESC,30)
	//[03] - CBC->CBC_LOCAL
	//[04] - CBC->CBC_LOCALI
	//[05] - CBC->CBC_LOTECT
	//[06] - CBC->CBC_NUMLOT
	//[07] - CBC->CBC_NUMSER
	//[08] - SB3->B3_CLASSE
	//[09] - SALDO EM ESTOQUE
	//[10] - QTD. ELEITA
	For nI:=1 To Len(aProdLido)
		If nLin > 59 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
			ImpCabec(cStatus)
		Endif

		If lUsaCB001 .and.  lPrintEtiq
			ImpCbcDet4(nI,aProdLido)
			While .T.
				If nLin > 59 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
					ImpCabec(cStatus)
				Endif
				nPos := AsCan(aEtiqLida,{|x| x[1]+x[2]+x[3]+x[4]+x[5]+x[6]==aProdLido[nI,1]+aProdLido[nI,3]+aProdLido[nI,4]+aProdLido[nI,5]+aProdLido[nI,6]+aProdLido[nI,7]})
				If Empty(nPos)
					Exit
				EndIf
				@nLin,016 PSAY aEtiqLida[nPos,7]+" :"
				@nLin,034 PSAY aEtiqLida[nPos,8] Picture cPicSB2
				nLin++
				aDel(aEtiqLida,nPos)
				aSize(aEtiqLida,Len(aEtiqLida)-1)
			EndDo
			nLin+=2
		Else
			ImpCbcDet3(nI,aProdLido)
		EndIf
	Next
	cCodInv := CBA->CBA_CODINV
	CBA->(DbSkip())
Enddo

If nLin # 06
	@nLin,000 PSAY ""
Endif

SET DEVICE TO SCREEN
If aReturn[5]==1
	DbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif
MS_FLUSH()
RestArea(aAreaCBA)
Return


/////////////////////////////////////////////////
// FUNCOES GENERICAS                           //
////////////////////////////////////////////////

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบFuno    ณImpCabec     บAutor  ณACD                 บ Data ณ10/02/05  บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDescricao ณImprime o Cabecalho das Paginas                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณACDR030                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function ImpCabec(cStatus)
Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
nLin:= 06
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบFuno    ณImpCbcDet1   บAutor  ณACD                 บ Data ณ10/02/05  บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDescricao ณImprime o Detalhe do Cabecalho das Paginas                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณACDR030                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function ImpCbcDet1(lImp,lQuebra)
Local cDescStat	 := STR0022 //"NAO INICIADO"
Local cNomeOpe	 := ""
Local nCodCBA    := 0

Default lImp     := .t.
Default lQuebra  := .f.

CB1->(DbSetOrder(1))
If CB1->(DbSeek(xFilial("CB1")+cCodOpe,.F.))
   cNomeOpe := Left(CB1->CB1_NOME,15)
EndIf

If Empty(CBA->CBA_STATUS)
   cDescStat := STR0022 //"NAO INICIADO"
ElseIf CBA->CBA_STATUS == "1"
   cDescStat := STR0023 //"EM ANDAMENTO"
ElseIf CBA->CBA_STATUS == "2"
   cDescStat := STR0024 //"EM PAUSA"
ElseIf CBA->CBA_STATUS == "3"
   cDescStat := STR0025 //"CONTADO"
ElseIf CBA->CBA_STATUS == "4"
   cDescStat := STR0026    //"FINALIZADO"
ElseIf CBA->CBA_STATUS == "5"
   cDescStat := STR0027 //"PROCESSADO"
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAnalisando Classificacao por curva ABC                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cClasses := ""
If CBA->CBA_CLASSA=="1"
	cClasses+="A"
EndIf
If CBA->CBA_CLASSB=="1"
	cClasses+="B"
EndIf
If CBA->CBA_CLASSC=="1"
	cClasses+="C"
EndIf

If lQuebra
	nLin++
	@nLin, 000 PSAY Replicate("_",220)
	nLin+=2
EndIf

@nLin, 000 PSAY STR0028+CBA->CBA_CODINV //"MESTRE..............: "
@nLin, 034 PSAY STR0029+StrZero(nContagem,3) //"CONTAGEM.: "
@nLin, 050 PSAY STR0030+cCodOpe //"OPERADOR.: "
@nLin, 070 PSAY "- "+cNomeOpe
@nLin, 109 PSAY STR0031+CBA->CBA_LOCAL //"ARMAZEM.: "
//@nLin, 109 PSAY "ENDERECO.: "+Alltrim(CBA->CBA_LOCALI)
@nLin, 131 PSAY STR0032+If(Empty(cClasses),"-",cClasses) //"ANALISA CLASSE ABC...: "
@nLin, 170 PSAY STR0033+cDescStat //"STATUS...: "
nLin++
If CBA->CBA_TIPINV=="2"
	@nLin, 000 PSAY STR0034 //"TIPO DE INVENTARIO..: Por Endereco"
	@nLin, 050 PSAY STR0035+Alltrim(CBA->CBA_LOCALI) //"ENDERECO..:"
Else
	@nLin, 000 PSAY STR0036 //"TIPO DE INVENTARIO..: Por Produto"
	If Empty(CBA->CBA_PROD)
		@nLin, 050 PSAY STR0037 //"PRODUTO..: Todos os Produtos"
	Else
		SB1->(DbSeek(xFilial("SB1")+CBA->CBA_PROD))
		@nLin, 050 PSAY STR0038+CBA->CBA_PROD //"PRODUTO..: "
		nCodCBA := Len(Rtrim(CBA->CBA_PROD))
		nCodCBA := IIF(Len(Rtrim(CBA->CBA_PROD)) <= 27, nCodCBA+1, nCodCBA)
		@nLin, 062 + nCodCBA PSAY "- "+Left(SB1->B1_DESC,100)
	EndIf
EndIf

nLin:=nLin+2
If lImp
	ImpCbcDet2()
EndIf

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบFuno    ณImpCbcDet2   บAutor  ณACD                 บ Data ณ10/02/05  บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDescricao ณImprime o Detalhe do Cabecalho dos Produtos                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณACDR030                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function ImpCbcDet2()

	@nLin,000 PSAY STR0039 				//"PRODUTO"
	@nLin,nTamCod PSAY STR0040 			//"|DESCRICAO"
	@nLin,nTamCod+nTamDesc PSAY STR0041 //"|ARMAZEM"
	@nLin,nTamTot + 9 PSAY STR0042 		//"|ENDERECO" 072
	@nLin,nTamTot + 25 PSAY STR0043 	//"|LOTE" 080
	@nLin,nTamTot + 36 PSAY STR0044 	//"|SUB-LOTE" 088 
	@nLin,nTamTot + 45 PSAY STR0045 	//"|N.SERIE" 098
	@nLin,nTamTot + 66 PSAY STR0046 	//"|CLASSE ABC"
	@nLin,nTamTot + 78 PSAY STR0047 	//"|SALDO ESTOQUE"
	@nLin,nTamTot + 98 PSAY STR0048 	//"|SLD.INVENTARIADO"
	nLin++
Return

/*/{Protheus.doc} ImpCbcDet3
	Fun็ใo responsแvel por imprimir a linha dos itens quando nใo utilizado CB0
	@type  Function
	@author Squad Entradas
	@since 14/01/2021
	@version 1.0
/*/
Static Function ImpCbcDet3(nI,aProdLido)

	@nLin, 000 PSAY aProdLido[nI,1]
	@nLin, nTamCod PSAY "|"
	@nLin, nTamCod + 1 PSAY aProdLido[nI,2]
	@nLin, nTamCod + nTamDesc PSAY "|"
	@nLin, nTamTot + 1 PSAY aProdLido[nI,3]
	@nLin, nTamTot + 9 PSAY "|"
	@nLin, nTamTot + 10 PSAY aProdLido[nI,4]
	@nLin, nTamTot + 25 PSAY "|"
	@nLin, nTamTot + 26 PSAY aProdLido[nI,5]
	@nLin, nTamTot + 36 PSAY "|"
	@nLin, nTamTot + 37 PSAY aProdLido[nI,6]
	@nLin, nTamTot + 45 PSAY "|"
	@nLin, nTamTot + 46 PSAY aProdLido[nI,7] 
	@nLin, nTamTot + 66 PSAY "|"
	@nLin, nTamTot + 67 PSAY aProdLido[nI,8]
	@nLin, nTamTot + 78 PSAY "|"
	@nLin, nTamTot + 78 PSAY aProdLido[nI,9]  Picture cPicSB2
	@nLin, nTamTot + 97 PSAY "|"
	@nLin, nTamTot + 97 PSAY aProdLido[nI,10] Picture cPicSB2
	nLin++

Return

/*/{Protheus.doc} ImpCbcDet4
	Fun็ใo responsแvel por imprimir a linha dos itens quando utilizado CB0
	@type  Function
	@author Squad Entradas
	@since 14/01/2021
	@version 1.0
/*/
Static Function ImpCbcDet4(nI,aProdLido)

	@nLin, 000 PSAY aProdLido[nI,1]
	@nLin, nTamCod + 1 PSAY aProdLido[nI,2]
	@nLin, nTamTot + 1 PSAY aProdLido[nI,3]
	@nLin, nTamTot + 10 PSAY aProdLido[nI,4]
	@nLin, nTamTot + 26 PSAY aProdLido[nI,5]
	@nLin, nTamTot + 37 PSAY aProdLido[nI,6]
	@nLin, nTamTot + 46 PSAY aProdLido[nI,7]
	@nLin, nTamTot + 67 PSAY aProdLido[nI,8]
	@nLin, nTamTot + 79 PSAY aProdLido[nI,9]  Picture cPicSB2
	@nLin, nTamTot + 97 PSAY aProdLido[nI,10] Picture cPicSB2
	nLin++
	@nLin,016 PSAY STR0015 //"COD. ETIQUETA ELEITAS"
	@nLin,040 PSAY STR0016 //"QUANTIDADE"
	nLin++

Return
