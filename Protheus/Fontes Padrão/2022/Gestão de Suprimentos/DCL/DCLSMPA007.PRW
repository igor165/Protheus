#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLSMPA007()
Edicao da tabela LX5 - Tabela 13-> Vasilhames GLP ANP
Adaptação da função TSMPA007
@author Itamar Oliveira
@since 30/11/2004
@version 1.0
/*/
//-------------------------------------------------------------------
Function DCLSMPA007()
Local lRet			:= .T.
Local aArea			:= GetArea()
Local aSX5Area		:= SX5->( GetArea() )
Local aSC5Area		:= SC5->( GetArea() )
Local aDH4Area		:= DH4->( GetArea() )

Local cMens	 		:= ""
Local nQ		 	:= 0
Local nCon		 	:= 0
Local nFiliais 		:= 0
Local cSeek  		:= Nil
Local cWhile		:= Nil
Local cQuery 		:= Nil
Local cX5Key 		:= Nil
Local cX5Des 		:= Nil

Local aYesFields	:= {}
Local aNoFields 	:= {}
Local lOnlyYes		:= .T.

If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
	Return
EndIf

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

nOpcx   := 3      //Adcionado o valor "3" na Variavel para
                  //permitir a edicao do conteudo
cTabela := "HL"  // Tabela 13 Vasilhas de GLP ANP
aFiliais := IIf( FwModeAccess( "SX5", 3 ) == "E", FwAllFilial( Nil, Nil, FwGrpCompany(), .T. ),  { FWxFilial( 'SX5' ) } )

dbSelectArea( "SC5" )
SC5->( dbSetOrder( 9 ) )//C5_FILIAL+C5_CODVGLP

dbSelectArea( "DH4" )
DH4->( dbSetOrder( 5 ) ) //DH4_FILIAL+DH4_CODVGL

dbSelectArea( "SX5" )
SX5->( dbSetOrder( 1 ) )
SX5->( dbSeek( xFilial( 'SX5' ) + cTabela ) )

aHeader := {}
aCols  	:= {}
cSeek  	:= FWxFilial('SX5') + cTabela
cWhile 	:= "X5_FILIAL+X5_TABELA"
aYesFields	:= { 'X5_CHAVE', 'X5_DESCRI' }
aNoFields 	:= { 'X5_FILIAL', 'X5_TABELA', 'X5_DESCSPA', 'X5_DESCENG' }
cQuery := "SELECT SX5.X5_CHAVE, SX5.X5_DESCRI, SX5.R_E_C_N_O_ FROM "+ RetSQLName( 'SX5' ) +" SX5 WHERE SX5.X5_FILIAL = '"+ FWxFilial( 'SX5' ) +"' AND SX5.X5_TABELA = '"+ cTabela +"' AND SX5.D_E_L_E_T_ = ' ' "
FillGetDados(4,"SX5",1,cSeek,{|| &cWhile },{||.T.},aNoFields, aYesFields, lOnlyYes , cQuery,/*bMontCols*/)

//+--------------------------------------------------------------+
//¦ Variaveis do Cabecalho do Modelo 2                           ¦
//+--------------------------------------------------------------+
cChave  := AllTrim( SX5->X5_TABELA )
cDescri := Substr(SX5->X5_DESCRI, 1, 35)

//+--------------------------------------------------------------+
//¦ Variaveis do Rodape do Modelo 2                              ¦
//+--------------------------------------------------------------+
nLinGetD :=0

//+--------------------------------------------------------------+
//¦ Titulo da Janela                                             ¦
//+--------------------------------------------------------------+
cTitulo := cDescri

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
AADD(aC, {"cChave" , {20,05}, "Tabela ", "@!", " ", "", .F.})
AADD(aC, {"cDescri", {20,50}, " "      , "@!", " ", "", .F.})

aR := {}
aCGD := {44,5,118,315}

//+--------------------------------------------------------------+
//¦ Validacoes na GetDados da Modelo 2                           ¦
//+--------------------------------------------------------------+
cLinhaOk := "(!Empty(aCols[n,2]) .Or. aCols[n,3])"
cTudoOk  := "AllwaysTrue()"

//+--------------------------------------------------------------+
//¦ Chamada da Modelo2                                           ¦
//+--------------------------------------------------------------+
// Se Modelo2() retornou .t., confirmou, caso contrario cancelou
// No Windows existe a funcao de apoio CallMOd2Obj() que retorna o
// objeto Getdados Corrente

n := 1
If Modelo2(cTitulo, aC, aR, aCGD, nOpcx, cLinhaOk, cTudoOk,,,,999999)
	Begin Transaction
	For nCon := 1 To Len(aCols)
		cX5Key := GdFieldGet( 'X5_CHAVE' , nCon, .F.,  aHeader , aCols )
		cX5Des := GdFieldGet( 'X5_DESCRI', nCon, .F.,  aHeader , aCols )
		If aCols[ nCon, Len( aHeader ) + 1] // Ultima posicao de cada elemento aCols

			// Determina se o registro foi excluido ou nao
			For nFiliais := 1 TO Len( aFiliais ) // Quantas filiais existirem
				If SX5->( dbSeek( aFiliais[ nFiliais ] + cTabela + cX5Key ) )
					If SC5->( dbSeek( FWxFilial( 'SC5' ) + cX5Key ) )
						cMens:="O modal " + AllTrim( cX5Key ) + " nao pode ser excluido por estar "
						cMens:=cMens+"relacionado com pedidos de vendas."
						ApMsgAlert( cMens, 'Atencao' )
						disarmTransaction()
						Exit
					Else
						If DH4->( dbSeek( FWxFilial( 'DH4' ) + cX5Key ) )
							cMens:="O modal " + AllTrim( cX5Key ) + " nao pode ser excluido por estar "
							cMens:=cMens+"relacionado com notas de entradas."
							ApMsgAlert( cMens, 'Atencao' )
							disarmTransaction()
							Exit
						Else
							RecLock("SX5" ,.F. )
							SX5->( dbDelete() )
							SX5->( MsUnLock() )
						EndIf
					EndIf
				EndIf
			Next
		Else
			If !( Empty( cX5Key ) ) // Caso a chave esteja em branco nao GRAVO
				For nFiliais := 1 To Len( aFiliais ) // Quantas filiais existirem
					lFound := !SX5->( dbSeek( aFiliais[ nFiliais ] + cTabela + cX5Key ) )
					RecLock( "SX5", lFound )
					If !( lFound )
						If !( AllTrim( cX5Des ) == AllTrim( SX5->X5_DESCRI ) )
							Replace X5_DESCRI with cX5Des
						EndIf
					Else
						Replace X5_FILIAL with aFiliais[ nFiliais ]
						Replace X5_TABELA with cTabela
						Replace X5_CHAVE  with cX5Key
						Replace X5_DESCRI with cX5Des
					EndIf
					SX5->( MsUnlock() )
				Next nFiliais

			EndIf
		EndIf
	Next nCont

	End Transaction
	dbCommitAll()

EndIf


RestArea( aSX5Area )
RestArea( aSC5Area )
RestArea( aDH4Area )
RestArea( aArea )
Return lRet