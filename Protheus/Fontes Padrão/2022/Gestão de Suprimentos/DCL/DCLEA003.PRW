#INCLUDE "protheus.ch"

#DEFINE MB_ICONASTERISK             64

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLEA003
Manutencao No Cadastro de Medicoes Diarias

@author TOTVS
@since 09/02/2017
@version P12
/*/
//-------------------------------------------------------------------
Function DCLEA003()

If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
	Return
EndIf

SetPrvt("CCADASTRO,AROTINA,")

cCadastro := "Cadastro de Medicoes Diarias"

aROTINA := {{"PESQUISAR","AXPESQUI",0,1},{"VISUALIZAR","AXVISUAL",0,2},{"INCLUI","DCEA03I()",0,3},{"ALTERAR","DCEA03A()",0,4},{"EXCLUIR","DCEA03T()",0,5},{"Faixas com Fatores","DCEA03F()",0,4}}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ No caso do ambiente DOS, desenha a tela padrao de fundo             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbSelectArea("DH7")
cDelFunc	:= "DCEA03EXC()"
dbSetOrder(1)
mBrowse( 6,1,22,75,"DH7")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} DCEA03F
Edicao da tabela D3A - FAIXA HORARIA

@author TOTVS
@since 09/02/2017
@version P12
/*/
//-------------------------------------------------------------------
Function DCEA03F()
Local nInd		:= 0
Local nXnd		:= 0
Local nContador	:= 0
Local aAreaSB1	:= SB1->(GetArea())
Local cIniCpos	:= '+D3A_ITEM'
Local lOnlyYes 	:= .T.
Local nUsado  	:= 0
Local aAux    	:= {}
Local lFound	:= .F.
Local cProdItem	:= ''

Local cSeek  	:= FWxFilial('D3A') + DTOS( DH7->DH7_DATAME ) + DH7->DH7_CODPRO //D3A_FILIAL+DTOS(D3A_DATA)+D3A_CODPRO+D3A_ITEM
Local cWhile 	:= "D3A_FILIAL+DTOS( D3A_DATA )+D3A_CODPRO"
Local aNoFields := { 'D3A_DATA', 'D3A_CODPRO', 'D3A_DESCPR', 'D3A_ALI_WT', 'D3A_REC_WT' }
Local aYesFields := { 'D3A_DESPRO', 'D3A_ITEM', 'D3A_TANQUE', 'D3A_HORAIN', 'D3A_HORAFI', 'D3A_TEMPTQ', 'D3A_TEMPAM', 'D3A_DENSID', 'D3A_FATOR' }



SetPrvt("NOPCX,CTABELA,AFILIAIS,CEMPRESA,NREGSM0,AHEADER")
SetPrvt("NUSADO,X5_FILIAL,X5_TABELA,X5_CHAVE,X5_DESCRI,CCHAVE")
SetPrvt("CDESCRI,ACOLS,NQ,NLINGETD,CTITULO,AC")
SetPrvt("AR,ACGD,CLINHAOK,CTUDOOK,N,NFILIAIS")
SetPrvt("NOPCX,NUSADO,AHEADER,ACOLS,CCHAVE,CDESCRI")
SetPrvt("NLINGETD,CTITULO,AC,AR,ACGD,CLINHAOK,CTUDOOK,AFILIAIS,CEMPRESA,NREGSM0")


//+--------------------------------------------------------------+
//¦ Opcao de acesso para o Modelo 2                              ¦
//+--------------------------------------------------------------+
// 3,4 Permitem alterar getdados e incluir linhas
// 6 So permite alterar getdados e nao incluir linhas
// Qualquer outro numero so visualiza

nOpcx   := 3
cCHAVE  := DTOS(DH7->DH7_DATAME)+DH7->DH7_CODPRO  // Tabela 93 Regiao de Vendas
Private cLinhaOk  := "DCEA03LinhaOk()"      //Validacao a cada linha da getdados
Private cTudoOk   := "T_TudoOk()" //Validacao ao confirmar

//+--------------------------------------------------------------+
//¦ Montando aHeader                                             ¦
//+--------------------------------------------------------------+
aHeader := {}
aCols  := {}
cSeek  := FWxFilial('D3A') + DTOS( DH7->DH7_DATAME ) + DH7->DH7_CODPRO //D3A_FILIAL+DTOS(D3A_DATA)+D3A_CODPRO+D3A_ITEM
cWhile := "D3A_FILIAL+DTOS( D3A_DATA )+D3A_CODPRO"
aYesFields := { 'D3A_DESPRO', 'D3A_ITEM', 'D3A_TANQUE', 'D3A_HORAIN', 'D3A_HORAFI', 'D3A_TEMPTQ', 'D3A_TEMPAM', 'D3A_DENSID', 'D3A_FATOR' }
aNoFields := { 'D3A_DATA', 'D3A_CODPRO', 'D3A_DESCPR', 'D3A_ALI_WT', 'D3A_REC_WT' }
FillGetDados(4,"D3A",1,cSeek,{|| &cWhile },{||.T.},aNoFields, aYesFields, lOnlyYes ,/*cQuery*/,/*bMontCols*/)



//+--------------------------------------------------------------+
//¦ Variaveis do Cabecalho do Modelo 2                           ¦
//+--------------------------------------------------------------+
dData   := DH7->DH7_DATAME
cCod    := DH7->DH7_CODPRO
cDesc   := POSICIONE( "SB1", 1, XFILIAL( "SB1" ) + cCod, "B1_DESC")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona os itens da tabela conforme a filial corrente      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len( aCols ) == 1 .And. Empty( aCols[ 1, GdFieldPos( "D3A_ITEM", aHeader ) ] )
	aCols[ 1, GdFieldPos( "D3A_ITEM", aHeader ) ] := StrZero( 1, TamSx3( "D3A_ITEM" )[1] )
EndIf


//+--------------------------------------------------------------+
//¦ Variaveis do Rodape do Modelo 2                              ¦
//+--------------------------------------------------------------+

nLinGetD :=0

//+--------------------------------------------------------------+
//¦ Titulo da Janela                                             ¦
//+--------------------------------------------------------------+

cTitulo := 'Tabela de fatores'

//+--------------------------------------------------------------+
//¦ Array com descricao dos campos do Cabecalho do Modelo 2      ¦
//+--------------------------------------------------------------+
// aC[n,1] = Nome da Variavel Ex.:"cCliente"
// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
// aC[n,3] = Titulo do Campo
// aC[n,4] = Picture
// aC[n,5] = Validacao
// aC[n,6] = F3
// aC[n,7] = Se campo e' editavel .t. se nao .f.

aC := {}
AADD(aC, {"dData" , {20,05}, "Data"      , "@!", " ", "", .F.})
AADD(aC, {"cCod"  , {20,58}, "Codigo"    , "@!", " ", "SB1", .F.})
AADD(aC, {"cDesc" , {36,05}, "Descricao" , "@!", " ", "", .F.})

//+--------------------------------------------------------------+
//¦ Array com descricao dos campos do Rodape do Modelo 2         ¦
//+--------------------------------------------------------------+
// aR[n,1] = Nome da Variavel Ex.:"cCliente"
// aR[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
// aR[n,3] = Titulo do Campo
// aR[n,4] = Picture
// aR[n,5] = Validacao
// aR[n,6] = F3
// aR[n,7] = Se campo e' editavel .t. se nao .f.

aR := {}
//+--------------------------------------------------------------+
//¦ Array com coordenadas da GetDados no modelo2                 ¦
//+--------------------------------------------------------------+

aCGD := {100,10,118,300}
//+--------------------------------------------------------------+

//¦ Validacoes na GetDados da Modelo 2                           ¦
//+--------------------------------------------------------------+

//cLinhaOk := ""//(!Empty(aCols[n,2]) .Or. aCols[n,3])"  // .And. ExecBlock('YRFATA16',.F.,.F.)"
// Coloquei comentario, pois imagino
// que nesta funcao era tratado _nItem
// e aRecno, removi pois era desnecessario
// caso tenha algum tratamento de mensagem
// inclua somente ele
cTudoOk  := "AllwaysTrue()"

//+--------------------------------------------------------------+
//¦ Chamada da Modelo2                                           ¦
//+--------------------------------------------------------------+
// Se Modelo2() retornou .t., confirmou, caso contrario cancelou

// No Windows existe a funcao de apoio CallMOd2Obj() que retorna o
// objeto Getdados Corrente

// Modelo2(cTitulo, aC, aR, aCGD, nOpcx, cLineOk,   cAllOk,aGetsGD,bF4,cIniCpos,nMax,aCordW,lDelGetD,lMaximized, aButtons)
n := 1
If Modelo2(cTitulo, aC, aR, aCGD, nOpcx, cLinhaOk, cTudoOk,,,cIniCpos,999,,,.T.)
	D3A->( dbSetOrder( 1 ) )
	For nContador := 1 To Len( aCols )
		cProdItem	:= GdFieldGet( 'D3A_ITEM', nContador )
		If aCols[nContador, Len( aHeader ) + 1 ] // Ultima posicao de cada elemento aCols
			D3A->( dbSetOrder( 1 ) ) //D3A_FILIAL, D3A_DATA, D3A_CODPRO, D3A_ITEM
			If D3A->( dbSeek( FWxFilial( 'D3A' ) + Dtos( dData ) + cCod + cProdItem ) )
				RecLock( 'D3A', .F. )
				D3A->( dbDelete() )
				D3A->( MsUnLock() )
			EndIf
		Else
			lFound := !D3A->( dbSeek( FWxFilial( 'D3A' ) + Dtos( dData ) + cCod + cProdItem ) )
			RecLock( 'D3A', lFound )
			D3A->D3A_FILIAL := FWxFilial( 'D3A' )
			D3A->D3A_DATA   := DH7->DH7_DATAME
			D3A->D3A_CODPRO := DH7->DH7_CODPRO

			For nXnd := 1 To Len( aHeader )
				If D3A->( FieldPos( aHeader[ nXnd, 2 ] ) ) > 0
					D3A->( FieldPut( FieldPos( aHeader[ nXnd, 2 ] ), GdFieldGet( aHeader[ nXnd, 2 ], nContador ) ) )
				EndIf
			Next nXnd
			D3A->( MsUnLock() )

		EndIf
	Next nContador
EndIf

dbCommitAll()
RestArea(aAreaSB1)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} DCEA03LinhaOk

@author TOTVS
@since 09/02/2017
@version P12
/*/
//-------------------------------------------------------------------
Function DCEA03LinhaOk()
Local I:=0
Local _lRet 	     := .T.
Local _nPosTanque    := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="D3A_TANQUE" })
Local _nPosHoraini   := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="D3A_HORAIN" })
Local _nPosHorafim   := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="D3A_HORAFI" })
Local _nPosTemp      := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="D3A_TEMPTQ" })
Local _nPosFator     := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="D3A_FATOR"  })
Local _nPosItem		 := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="D3A_ITEM"   })

if (Empty(aCols[n,_nPosTanque]) .AND.;
	Empty(aCols[n,_nPosHoraini]) .AND.;
	Empty(aCols[n,_nPosHorafim]) .AND.;
	Empty(aCols[n,_nPosTemp]) .AND.;
	Empty(aCols[n,_nPosFator])) .OR.  aCols[n, Len(aHeader) + 1]
	_lRet := .T.
	aCols[n, Len(aHeader) + 1]:=.T.
ELSE
	IF Empty(aCols[n,_nPosTanque]) .OR.;
		Empty(aCols[n,_nPosHoraini]) .OR.;
		Empty(aCols[n,_nPosHorafim]) .OR.;
		Empty(aCols[n,_nPosTemp]) .OR.;
		Empty(aCols[n,_nPosFator])
		Help("",1,"OBRIGAT")
		_lRet := .F.
	endif
	IF _lret .AND. VAL(aCols[n,_nPosHoraini]) >= VAL(aCols[n,_nPosHorafim])
		MessageBox("Hora Inicial Maior ou Igual Hora Final","Atencao",MB_ICONASTERISK)
		_lRet := .F.
	ENDIF

	IF _lRet
		FOR I:=1 TO LEN(ACOLS)
			IF I>1 .AND. VAL(aCols[I-1,_nPosHorafim]) <> VAL(aCols[I,_nPosHoraini]) .AND. ! aCols[I-1, Len(aHeader) + 1] .AND. !aCols[I, Len(aHeader) + 1];
			    .and. aCols[I-1,_nPosTanque] == aCols[I,_nPosTanque]
				MessageBox("Hora Inicial diferente da Hora Final Anterior ","Atencao",MB_ICONASTERISK)
				_lRet:=.F.
			ENDIF
			IF  I < LEN(ACOLS) .AND. VAL(aCols[I+1,_nPosHoraIni]) <> VAL(aCols[I,_nPosHoraFim])   .AND. ! aCols[I+1, Len(aHeader) + 1] .AND. !aCols[I, Len(aHeader) + 1];
			    .and. aCols[I+1,_nPosTanque] == aCols[I,_nPosTanque]
				MessageBox("Hora Final diferente da Hora Inicial Seguinte ","Atencao",MB_ICONASTERISK)
				_lRet:=.F.
			ENDIF
		NEXT
	ENDIF

	If _lret .AND. DH6->DH6_CODPRO <> cCod
		DH6->(DBSEEK(XFILIAL()+aCols[n,_nPosTanque]))
		If DH6->DH6_CODPRO <> cCod
			MessageBox("Produto Nao Pertence a este Tanque","Atencao",MB_ICONASTERISK)
			_lRet := .F.
		EndIf
	EndIf

ENDIF
Return(_lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} DCEA03EXC

@author TOTVS
@since 09/02/2017
@version P12
/*/
//-------------------------------------------------------------------
Function DCEA03EXC()
If MsgYesNo("Confirma exclusao da Medicao?", "Atencao" )
	DBSELECTAREA("D3A")
	D3A->(DbSetOrder(1))
	While D3A->(DbSeek(Xfilial() + dToS(DH7->DH7_DATAME) + DH7->DH7_CODPRO)) .AND. !(EoF())
		RECLOCK("D3A",.F.)
		DELETE RECORD RECNO()
		MSUNLOCK()
	ENDDO
	DBSELECTAREA("DH7")
	Return(.T.)
Else
	Return .F.
EndIf

//-------------------------------------------------------------------
/*/{Protheus.doc} DCEA03A

@author TOTVS
@since 09/02/2017
@version P12
/*/
//-------------------------------------------------------------------
Function DCEA03A()
IF GETMV("MV_ULMES")>=DH7->DH7_DATAME
	MessageBox("Fechamento ja Promovido para esta Data: " + DTOC(DH7->DH7_DATAME),"Atencao",MB_ICONASTERISK)
ELSE
	AxAltera("DH7",DH7->(RECNO()),4,,,,"DCEA03TOk()")
ENDIF
Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} DCEA03T

@author TOTVS
@since 09/02/2017
@version P12
/*/
//-------------------------------------------------------------------
Function DCEA03T()
IF GETMV("MV_ULMES")>=DH7->DH7_DATAME
	MessageBox("Fechamento ja Promovido para esta Data: " + DTOC(DH7->DH7_DATAME),"Atencao",MB_ICONASTERISK)
ELSE
	AxDeleta("DH7",DH7->(RECNO()),5)
ENDIF
Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} DCEA03I

@author TOTVS
@since 09/02/2017
@version P12
/*/
//-------------------------------------------------------------------
Function DCEA03I()
IF GETMV("MV_ULMES")>=DDATABASE
	MessageBox("Fechamento ja Promovido para esta Data: " + DTOC(DH7->DH7_DATAME),"Atencao",MB_ICONASTERISK)
ELSE
	AxInclui("DH7",DH7->(RECNO()),3,,,,"DCEA03TOk()")
ENDIF
Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} DCEA03TOk
Validação da inclusão
@author jose.eulalio
@since 23/03/2017
@version P12
/*/
//-------------------------------------------------------------------
Function DCEA03TOk()
Local lRet	:= .T.

DH7->(DbSetOrder(1))//DH7_FILIAL+DTOS(DH7_DATAME)+DH7_CODPRO+DH7_TANQUE
If DH7->(DbSeek(xFilial("DH7") + M->(DTOS(DH7_DATAME)) + M->DH7_CODPRO + M->DH7_TANQUE))
	lRet := .F.
	MessageBox("Já existe medição nesta data para este tanque. ","Atencao",MB_ICONASTERISK)
EndIf

Return lRet