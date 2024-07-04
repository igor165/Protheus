#INCLUDE "PROTHEUS.CH"
#INCLUDE "MANA100.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ DATA   ³ BOPS ³Program.³ALTERACAO                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³18.11.98³xxxxxx³Pilar   ³Alterada chave de validacao do SI2 para:       ³±±
±±³        ³      ³        ³DATA+NUM LOTE+NUM DOC+LINHA                    ³±±
±±³30.11.00³xxxxxx³A.Veiga ³Inclusao dos arquivo do loja                   ³±±
±±ÀÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ManA100  ³ Autor ³ Wagner/Wilson Jr      ³ Data ³ 14/09/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Check Program.                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ManA100()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaMan Advanced.                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Mana100()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL titulo :=STR0001	//"Checa Integridade dos arquivos Siga Advanced"
LOCAL cDesc1 :=STR0002	//"Este programa tem o objetivo de efetuar a checagem dos arquivos do "
LOCAL cDesc2 :=STR0003	//"m¢dulo Siga Advanced, fornecendo informa‡”es sobre os dados incorretos. "
LOCAL cDesc3 :=""
Local lRet   := .F.

PRIVATE li:= 80
PRIVATE aArquivos := {}
PRIVATE aReturn := { "", 1,"", 2, 2, 1, "",1 }
PRIVATE nomeprog:="MANA100"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE m_pag   := 1
PRIVATE cbtxt 	:= SPACE(10)
PRIVATE cbcont	:= 0

cString := "SA1"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tela de Interface com usuãrio
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg1 TITLE STR0001 FROM 0,0 TO 215,460 PIXEL
@10,09 SAY STR0004 PIXEL // "      Este programa tem como objetivo efetuar a checagem dos "
@23,09 Say STR0005 PIXEL // "arquivos do modulo Siga Advanced, verificando a integridade dos" 
@36,09 Say STR0006 PIXEL // "dados migrados. Caso algum campo esteja com conteudo inconsistente," 
@49,09 Say STR0007 PIXEL // "o mesmo ser  listado, para que seja feita a correcao no arquivo" 
DEFINE SBUTTON FROM	85,168 TYPE 1 ENABLE ACTION (lRet:=Mana100a(@aArquivos),oDlg1:End())
DEFINE SBUTTON FROM 85,197 TYPE 2 ENABLE ACTION oDlg1:End()
ACTIVATE DIALOG oDlg1 CENTERED

If !lRet
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := "MANA100"            //Nome Default do relatorio em Disco

wnrel := SetPrint(cString,wnrel,"",@titulo,cDesc1,cDesc2,cDesc3,.F.,"")

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If lRet
	RptStatus({|lEnd| Mana100b() })
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura integridade dos dados de Entrada                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Set Filter To
Set Device To Screen

If aReturn[5] = 1
	Set Printer TO
	dbCommit( )
	Ourspool(wnrel)
Endif
MS_FLUSH()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MANA100B  ºAutor  ³Andre Veiga         º Data ³  04/12/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Mana100b
Local j

For j:=1 To Len( aArquivos )
	If aArquivos[j][1]
		cRot := "Check"+SubStr(aArquivos[j][2],1,3)+"()"
		&(cRot)
	EndIf
Next j
Roda(0,"","M")
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CheckSa1  ³ Autor ³ Wagner/Wilson Jr      ³ Data ³ 14/09/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Checagem do Cadastro de Clientes.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CheckSa1( )                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SigaMan Advanced.                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CheckSa1()
Private cAliasAtu := "SA1"

dbSelectArea("SA1")
dbSeek( cFilial )
SetRegua(RecCount())

While !Eof( ) .and. A1_FILIAL == cFilial
	
	IncRegua()
	a100CheckDup( "A1_COD+A1_LOJA" )
	
	If Empty( A1_NOME )
		a100Imprime(A1_COD+A1_LOJA ,STR0007  )	//"Nome nao preenchido"
	End
	
	If Empty( A1_NREDUZ )
		a100Imprime(A1_COD+A1_LOJA , STR0008 )	//"Nome Reduzido nao preenchido"
	End
	
	If Empty( A1_LOJA )
		a100Imprime(A1_COD+A1_LOJA , STR0009 )	//"Loja nao preenchida"
	End
	
	If ! (A1_TIPO $ "FLRSX")
		a100Imprime(A1_COD+A1_LOJA , STR0010)	//"Tipo Invalido"
	End
	
	If Empty( A1_END )
		a100Imprime(A1_COD+A1_LOJA , STR0011 ) //"Endereco nao preenchido"
	End
	
	If Empty( A1_MUN )
		a100Imprime(A1_COD+A1_LOJA , STR0012  ) //"Municipio nao preenchido"
	End
	
	IF !SX5->(dbSeek(xFilial("SX5")+"12"+SA1->A1_EST))
		a100Imprime(A1_COD+A1_LOJA ,STR0013 )	//"Estado da Federacao Invalido"
	End
	dbSkip( )
End

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CheckSa2  ³ Autor ³ Wagner/Wilson Jr      ³ Data ³ 14/09/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Checagem do Cadastro de Fornecedores.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CheckSa2( )                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SigaMan Advanced.                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CheckSa2()
PRIVATE cAliasAtu := "SA2"
dbSelectArea("SA2")
dbSeek( cFilial )
SetRegua(RecCount())

While !Eof( ) .and. A2_FILIAL == cFilial
	
	IncRegua()
	a100CheckDup( "A2_COD+A2_LOJA" )
	
	If Empty( A2_NOME )
		a100Imprime(A2_COD+A2_LOJA ,STR0007  )	//"Nome nao preenchido"
	End
	
	If Empty( A2_NREDUZ )
		a100Imprime(A2_COD+A2_LOJA , STR0008 ) //"Nome Reduzido nao preenchido"
	End
	
	If Empty( A2_LOJA )
		a100Imprime(A2_COD+A2_LOJA , STR0009) //"Loja nao preenchida"
	End
	
	If ! A2_TIPO $ " FJX"
		a100Imprime(A2_COD+A2_LOJA , STR0010) //"Tipo Invalido"
	End
	
	If Empty( A2_END )
		a100Imprime(A2_COD+A2_LOJA , STR0011 ) //"Endereco nao preenchido"
	End
	
	If Empty( A2_MUN )
		a100Imprime(A2_COD+A2_LOJA , STR0012 ) //"Municipio nao preenchido"
	End
	
	IF !SX5->(dbSeek(xFilial("SX5")+"12"+SA2->A2_EST))
		a100Imprime(A2_COD+A2_LOJA ,STR0013 )  //"Estado da Federacao Invalido"
	Endif
	dbSkip()
End

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CheckSa3  ³ Autor ³ Wagner/Wilson Jr      ³ Data ³ 14/09/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Checagem do Cadastro de Vendedores.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CheckSa3( )                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SigaMan Advanced.                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CheckSa3()
PRIVATE cAliasAtu := "SA3"
dbSelectArea("SA3")
dbSeek( cFilial )
SetRegua(RecCount())

While !Eof( ) .and. A3_FILIAL == cFilial
	
	IncRegua()
	a100CheckDup( "A3_COD" )
	
	If Empty( A3_NOME )
		a100Imprime(A3_COD , STR0007 ) //"Nome nao preenchido"
	End
	dbSkip()
End

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CheckSa6  ³ Autor ³ Wagner/Wilson Jr      ³ Data ³ 14/09/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Checagem do Cadastro de Bancos.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CheckSa6( )                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SigaMan Advanced.                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CheckSa6()
PRIVATE cAliasAtu := "SA6"
dbSelectArea("SA6")
dbSeek( cFilial )
SetRegua(RecCount())

While !Eof( ) .and. A6_FILIAL == cFilial
	
	IncRegua()
	a100CheckDup( "A6_COD+A6_AGENCIA+A6_NUMCON" )
	
	If Empty( A6_NOME )
		a100Imprime(A6_COD+A6_AGENCIA+A6_NUMCON , STR0007 ) //"Nome Nao preenchido"
	End
	If Empty( A6_AGENCIA )
		a100Imprime(A6_COD+A6_AGENCIA+A6_NUMCON , STR0014 )  //"Agencia nao preenchida"
	End
	If Empty( A6_NUMCON )
		a100Imprime(A6_COD+A6_AGENCIA+A6_NUMCON , STR0015 )  //"Num.Conta nao preenchido"
	End
	dbSkip()
End

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CheckSb1  ³ Autor ³ Wagner/Wilson Jr      ³ Data ³ 14/09/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Checagem do Cadastro de Produtos.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CheckSb1( )                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SigaMan Advanced.                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CheckSB1()
PRIVATE cAliasAtu := "SB1"
dbSelectArea("SB1")
dbSeek( cFilial )
SetRegua(RecCount())

While !Eof( ) .and. B1_FILIAL == cFilial
	
	IncRegua()
	a100CheckDup( "B1_COD" )
	
	If Empty( B1_DESC )
		a100Imprime(B1_COD,STR0016) //"Descricao nao Preenchida"
	End
	If Empty( B1_LOCPAD)
		a100Imprime(B1_COD,STR0017) //"Local Padrao nao preenchido"
	End
	If Empty(B1_UM)
		a100Imprime(B1_COD,STR0018) //"Un.Medida nao preenchida"
	End
	If Empty(B1_TIPO) .or. !SX5->(dbSeek(xFilial("SX5")+"02"+SB1->B1_TIPO))
		a100Imprime(B1_COD,STR0010) //"Tipo Invalido"
	End
	If !Empty(B1_GRUPO) .and. !SX5->(dbSeek(xFilial("SX5")+"02"+SB1->B1_TIPO))
		a100Imprime(B1_COD,STR0019) //"Grupo Invalido"
	End
	If !Empty(B1_CC) .and. !SI3->(dbSeek(xFilial("SI3")+SB1->B1_CC))
		a100Imprime(B1_COD,STR0020) //"Centro de Custo nao cadastrado"
	End
	dbSkip()
End
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CheckSb2  ³ Autor ³ Wagner/Wilson Jr      ³ Data ³ 14/09/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Checagem do Cadastro de Dados Fisicos/Financeiros.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CheckSb2( )                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SigaMan Advanced.                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CheckSB2()
PRIVATE cAliasAtu := "SB2"
dbSelectArea("SB2")
dbSeek( cFilial )
SetRegua(RecCount())

While !Eof( ) .and. B2_FILIAL == cFilial
	
	IncRegua()
	a100CheckDup( "B2_COD+B2_LOCAL" )
	
	If Empty( B2_LOCAL )
		a100Imprime(B2_COD+B2_LOCAL,STR0021) //"Local nao Preenchido"
	End
	If !(SB1->(dbSeek(xFilial("SB1")+SB2->B2_COD)))
		a100Imprime(B2_COD+B2_LOCAL,STR0022) //"Produto nao cadastrado"
	End
	dbSkip()
End

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CheckSb9  ³ Autor ³ Wagner/Wilson Jr      ³ Data ³ 14/09/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Checagem do Cadastro de Saldos Iniciais.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CheckSb9( )                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SigaMan Advanced.                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CheckSB9()
PRIVATE cAliasAtu := "SB9"
dbSelectArea("SB9")
dbSeek( cFilial )
SetRegua(RecCount())

While !Eof( ) .and. B9_FILIAL == cFilial
	
	IncRegua()
	a100CheckDup( "B9_COD+B9_LOCAL+Dtos(B9_DATA)" )
	
	If Empty( B9_LOCAL )
		a100Imprime(B9_COD+B9_LOCAL+DtoC(B9_DATA),STR0021) //"Local nao Preenchido"
	End
	If !(SB1->(dbSeek(xFilial("SB1")+SB9->B9_COD)))
		a100Imprime(B9_COD+B9_LOCAL+DtoC(B9_DATA),STR0022) //"Produto nao cadastrado"
	End
	dbSkip( )
End

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CheckSc1  ³ Autor ³ Wagner/Wilson Jr      ³ Data ³ 14/09/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Checagem do Cadastro de Solicitacoes de Compras.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CheckSc1( )                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SigaMan Advanced.                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CheckSC1()
PRIVATE cAliasAtu := "SC1"
dbSelectArea("SC1")
dbSeek( cFilial )
SetRegua(RecCount())

While !Eof( ) .and. C1_FILIAL == cFilial
	
	IncRegua()
	a100CheckDup( "C1_NUM+C1_ITEM" )
	
	If Empty( C1_QUANT )
		a100Imprime(C1_NUM+C1_ITEM,STR0023) //"Quantidade nao preenchida"
	End
	If !(SB1->(dbSeek(xFilial("SB1")+SC1->C1_PRODUTO)))
		a100Imprime(C1_NUM+C1_ITEM,STR0022) //"Produto nao cadastrado"
	End
	dbSkip( )
End

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CheckSc2  ³ Autor ³ Wagner/Wilson Jr      ³ Data ³ 14/09/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Checagem do Cadastro de Op's                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CheckSc2( )                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SigaMan Advanced.                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CheckSC2()
PRIVATE cAliasAtu := "SC2"
dbSelectArea("SC2")
dbSeek( cFilial )
SetRegua(RecCount())

While !Eof( ) .and. C2_FILIAL == cFilial
	
	IncRegua()
	a100CheckDup( "C2_NUM+C2_ITEM+C2_SEQUEN" )
	
	If Empty( C2_QUANT )
		a100Imprime(C2_NUM+C2_ITEM+C2_SEQUEN,STR0023) //"Quantidade nao preenchida"
	End
	
	If !(SB1->(dbSeek(xFilial("SB1")+SC2->C2_PRODUTO)))
		a100Imprime(C2_NUM+C2_ITEM+C2_SEQUEN,STR0022) //"Produto nao cadastrado"
	End
	
	dbSkip( )
	
End

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CheckSc5  ³ Autor ³ Wagner/Wilson Jr      ³ Data ³ 14/09/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Checagem do Cadastro de Pedidos de Vendas.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CheckSc5( )                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SigaMan Advanced.                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CheckSC5()
Local nx
Private cAliasAtu := "SC5"
dbSelectArea("SC5")
dbSeek( cFilial )
SetRegua(RecCount())

While !Eof( ) .and. C5_FILIAL == cFilial
	
	IncRegua()
	a100CheckDup( "C5_NUM" )
	
	If SC5->C5_TIPO$"BD"
		If !(SA2->(dbSeek(xFilial("SA2")+SC5->C5_CLIENTE+SC5->C5_LOJACLI)))
			a100Imprime(C5_NUM,STR0024) //"Fornecedor nao cadastrado"
		End
		If !(SA2->(dbSeek(xFilial("SA2")+SC5->C5_CLIENTE+SC5->C5_LOJAENT)))
			a100Imprime(C5_NUM,STR0025) //"Fornecedor entrega nao cadastrado"
		End
	Else
		If !(SA1->(dbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI)))
			a100Imprime(C5_NUM,STR0026) //"Cliente nao cadastrado"
		End
		If !(SA1->(dbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJAENT)))
			a100Imprime(C5_NUM,STR0027) //"Cliente entrega nao cadastrado"
		End
	Endif
	
	If !(SE4->(dbSeek(xFilial("SE4")+SC5->C5_CONDPAG)))
		a100Imprime(C5_NUM,STR0028) //"Cond.Pagto. nao cadastrada"
	End
	
	For nx := 1 to 5
		cNx := Strzero(nx,1)
		cVend := &("C5_VEND"+cNx)
		If !Empty(cVend)
			IF !(SA3->(dbSeek(xFilial("SA3")+cVend)))
				a100Imprime(C5_NUM,STR0029+cNx+STR0030) // "Vendedor "  "  nao cadastrado"
			End
		End
	Next
	If ! C5_TIPOCLI $ "FLRSX"
		a100Imprime(C5_NUM , STR0010) //"Tipo Invalido"
	End
	If ! C5_TIPO $ "NDPCIB"
		a100Imprime(C5_NUM , STR0031)  //"Tipo de pedido Invalido"
	End
	IF !(SC6->(dbSeek(xFilial("SC6")+SC5->C5_NUM)))
		a100Imprime(C5_NUM , STR0032)  //"Pedido sem itens"
	End
	dbSkip()
End

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CheckSc6  ³ Autor ³ Wagner/Wilson Jr      ³ Data ³ 14/09/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Checagem do Cadastro de Itens dos Pedidos de Vendas.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CheckSc6( )                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SigaMan Advanced.                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CheckSC6()
PRIVATE cAliasAtu := "SC6"
dbSelectArea("SC6")
dbSeek( cFilial )
SetRegua(RecCount())

While !Eof( ) .and. C6_FILIAL == cFilial
	
	IncRegua()
	a100CheckDup( "C6_NUM+C6_ITEM" )
	
	If !(SC5->(dbSeek(xFilial("SC5")+SC6->C6_NUM)))
		a100Imprime(C6_NUM+C6_ITEM,STR0033) //"Pedido nao cadastrado"
	End
	
	If !(SF4->(dbSeek(xFilial("SF4")+SC6->C6_TES))) .or. SC6->C6_TES < "500"
		a100Imprime(C6_NUM+C6_ITEM,STR0034) //"Tipo de Saida Invalido"
	End
	
	IF SC6->C6_CLI+SC6->C6_LOJA != SC5->C5_CLIENTE+SC5->C5_LOJAENT
		a100Imprime(C6_NUM+C6_ITEM,STR0035) //"Cliente incompativel com pedido"
	End
	
	IF Empty(C6_QTDVEN) .and. SC5->C5_TIPO$"DNB"
		a100Imprime(C6_NUM+C6_ITEM , STR0036) //"Quantidade nao preenchida"
	End
	
	IF Empty(C6_PRCVEN) .or. Empty(C6_VALOR)
		a100Imprime(C6_NUM+C6_ITEM , STR0037) //"Preco nao preenchido"
	End
	
	IF Empty(C6_CF)
		a100Imprime(C6_NUM+C6_ITEM , STR0038) //"C.F.O. nao preenchido"
	End
	
	IF Empty(C6_LOCAL)
		a100Imprime(C6_NUM+C6_ITEM , STR0021) //"Local nao preenchido"
	End
	
	IF Empty(C6_ENTREG)
		a100Imprime(C6_NUM+C6_ITEM , STR0039) //"Data de entrega nao preenchida"
	End
	
	If !(SB1->(dbSeek(xFilial("SB1")+SC6->C6_PRODUTO)))
		a100Imprime(C6_NUM+C6_ITEM,STR0022) //"Produto nao cadastrado"
	End
	dbSkip()
End

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CheckSc7  ³ Autor ³ Wagner/Wilson Jr      ³ Data ³ 14/09/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Checagem do Cadastro de Pedidos de Compras.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CheckSc7( )                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SigaMan Advanced.                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CheckSc7()
PRIVATE cAliasAtu := "SC7"
dbSelectArea("SC7")
dbSeek( cFilial )
SetRegua(RecCount())

While !Eof( ) .and. C7_FILIAL == cFilial
	
	IncRegua()
	a100CheckDup( "C7_NUM+C7_ITEM" )
	
	If !(SA2->(dbSeek(xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA)))
		a100Imprime(C7_NUM+C7_ITEM,STR0024) //"Fornecedor nao cadastrado"
	End
	If !(SE4->(dbSeek(xFilial("SE4")+SC7->C7_COND)))
		a100Imprime(C7_NUM+C7_ITEM,STR0028) //"Cond.Pagto. nao cadastrada"
	End
	IF Empty(C7_QUANT)
		a100Imprime(C7_NUM+C7_ITEM , STR0036) //"Quantidade nao preenchida"
	End
	IF Empty(C7_LOCAL)
		a100Imprime(C7_NUM+C7_ITEM , STR0021) //"Local nao preenchido"
	End
	IF Empty(C7_PRECO) .or. Empty(C7_TOTAL)
		a100Imprime(C7_NUM+C7_ITEM , STR0037) //"Preco nao preenchido"
	End
	IF Empty(C7_DATPRF)
		a100Imprime(C7_NUM+C7_ITEM , STR0039) //"Data Entrega nao preenchida "
	End
	IF Empty(C7_FILENT)
		a100Imprime(C7_NUM+C7_ITEM , STR0040) //"Filial de  Entrega nao preenchida "
	End
	If !(SB1->(dbSeek(xFilial("SB1")+SC7->C7_PRODUTO)))
		a100Imprime(C7_NUM+C7_ITEM,STR0022) //"Produto nao cadastrado"
	End
	dbSkip()
End
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CheckSd4  ³ Autor ³ Wagner/Wilson Jr      ³ Data ³ 14/09/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Checagem do Cadastro de Empenhos.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CheckSd4( )                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SigaMan Advanced.                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CheckSD4()
PRIVATE cAliasAtu := "SD4"
dbSelectArea("SD4")
dbSeek( cFilial )
SetRegua(RecCount())

While !Eof( ) .and. D4_FILIAL == cFilial
	
	IncRegua()
	IF Empty(D4_QUANT) .or. Empty(D4_QTDEORI)
		a100Imprime(D4_COD+D4_OP+D4_TRT , STR0036) //"Quantidade nao preenchida"
	End
	IF Empty(D4_LOCAL)
		a100Imprime(D4_COD+D4_OP+D4_TRT , STR0021) //"Local nao preenchido"
	End
	IF !(SC2->(dbSeek(xFilial("SC2")+SD4->D4_OP)))
		a100Imprime(D4_COD+D4_OP+D4_TRT , STR0041) //"Ordem de Producao Invalida"
	End
	IF Empty(D4_DATA)
		a100Imprime(D4_COD+D4_OP+D4_TRT , STR0042)	//"Data nao preenchida "
	End
	If !(SB1->(dbSeek(xFilial("SB1")+SD4->D4_COD)))
		a100Imprime(D4_COD+D4_OP+D4_TRT,STR0022) //"Produto nao cadastrado"
	End
	dbSkip()
End

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CheckSg1  ³ Autor ³ Wagner/Wilson Jr      ³ Data ³ 14/09/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Checagem do Cadastro de Estruturas.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CheckSg1( )                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SigaMan Advanced.                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CheckSg1()
PRIVATE cAliasAtu := "SG1"
dbSelectArea("SG1")
dbSeek( cFilial )
SetRegua(RecCount())

While !Eof( ) .and. G1_FILIAL == cFilial
	
	IncRegua()
	a100CheckDup( "G1_COD+G1_COMP+G1_TRT" )
	IF Empty(G1_QUANT)
		a100Imprime(G1_COD+G1_COMP , STR0036) //"Quantidade nao preenchida"
	End
	IF G1_INI >= G1_FIM
		a100Imprime(G1_COD+G1_COMP , STR0043) //"Datas de Validade Invalidas"
	End
	If !(SB1->(dbSeek(xFilial("SB1")+SG1->G1_COD)))
		a100Imprime(G1_COD+G1_COMP,STR0044) //"Produto Pai  nao cadastrado"
	End
	If !(SB1->(dbSeek(xFilial("SB1")+SG1->G1_COMP)))
		a100Imprime(G1_COD+G1_COMP,STR0045) //"Produto Filho nao cadastrado"
	End
	dbSkip()
End

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CheckSg2  ³ Autor ³ Wagner/Wilson Jr      ³ Data ³ 14/09/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Checagem do Cadastro de Operacoes.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CheckSg2( )                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SigaMan Advanced.                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CheckSg2()
PRIVATE cAliasAtu := "SG2"
dbSelectArea("SG2")
dbSeek( cFilial )
SetRegua(RecCount())

While !Eof( ) .and. G2_FILIAL == cFilial
	
	IncRegua()
	a100CheckDup( "G2_PRODUTO+G2_OPERAC" )
	IF Empty(G2_TPOPER)
		a100Imprime(G2_PRODUTO+G2_OPERAC , STR0046) //"Tempo nao preenchido"
	End
	If !(SB1->(dbSeek(xFilial("SB1")+SG2->G2_PRODUTO)))
		a100Imprime(G2_PRODUTO+G2_OPERAC,STR0022) //"Produto nao cadastrado"
	End
	dbSkip()
End
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CheckSe1  ³ Autor ³ Wagner/Wilson Jr      ³ Data ³ 14/09/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Checagem do Cadastro de Titulos a Receber.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CheckSe1( )                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SigaMan Advanced.                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CheckSE1()
Local nX
PRIVATE cAliasAtu := "SE1"
dbSelectArea("SE1")
dbSeek( cFilial )
SetRegua(RecCount())

While !Eof( ) .and. E1_FILIAL == cFilial
	
	IncRegua()
	a100CheckDup( "E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO" )
	
	If Empty(E1_NUM)
		a100Imprime(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO,STR0047) //"Numero nao preenchido"
	End
	
	If Empty(E1_EMISSAO)
		a100Imprime(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO,STR0048) //"Data Emissao nao preenchida"
	End
	
	If Empty(E1_VENCTO) .or. Empty(E1_VENCREA)
		a100Imprime(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO,STR0049) //"Data Vencimento nao preenchida"
	End
	
	If Empty(E1_TIPO) .or. !(SX5->(dbSeek(xFilial("SX5")+"05"+SE1->E1_TIPO)))
		a100Imprime(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO,STR0010) //"Tipo invalido"
	End
	
	If Empty(E1_VALOR) .or. Empty(E1_VLCRUZ)
		a100Imprime(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO,STR0050) //"Valor nao preenchido"
	End
	
	If Empty(E1_NATUREZ)  .or. !(SED->(dbSeek(xFilial("SED")+SE1->E1_NATUREZ)))
		a100Imprime(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO,STR0051) //"Natureza Invalida"
	End
	
	If Empty(E1_BAIXA) .and. NoRound(SE1->E1_SALDO,2) != NoRound(SE1->E1_VALOR,2)
		a100Imprime(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO,STR0052) //"Valores Orig/Saldo Incompativeis"
	End
	
	If NoRound(SE1->E1_SALDO,2) > NoRound(SE1->E1_VALOR,2)
		a100Imprime(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO,STR0053) //"Valores Orig/Saldo Incompativeis"
	End
	
	If !(SA1->(dbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA)))
		a100Imprime(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO,STR0026) //"Cliente nao cadastrado"
	End
	
	For nx := 1 to 5
		cNx := Strzero(nx,1)
		cVend := &("E1_VEND"+cNx)
		If !Empty(cVend)
			IF !(SA3->(dbSeek(xFilial("SA3")+cVend)))
				a100Imprime(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO,STR0029+cNx+STR0030) //"Vendedor "      "  nao cadastrado"
			End
		End
	Next
	dbSkip()
End

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CheckSe2  ³ Autor ³ Wagner/Wilson Jr      ³ Data ³ 14/09/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Checagem do Cadastro de Titulos a Pagar.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CheckSe2( )                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SigaMan Advanced.                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CheckSE2()
PRIVATE cAliasAtu := "SE2"
dbSelectArea("SE2")
dbSeek( cFilial )
SetRegua(RecCount())

While !Eof( ) .and. E2_FILIAL == cFilial
	
	IncRegua()
	a100CheckDup( "E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE" )
	
	If Empty(E2_NUM)
		a100Imprime(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE,STR0047) //"Numero nao preenchido"
	End
	If Empty(E2_EMISSAO)
		a100Imprime(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE,STR0048) //"Data Emissao nao preenchida"
	End
	If Empty(E2_VENCTO) .or. Empty(E2_VENCREA)
		a100Imprime(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE,STR0049) //"Data Vencimento nao preenchida"
	End
	If Empty(E2_TIPO) .or. !(SX5->(dbSeek(xFilial("SX5")+"05"+SE2->E2_TIPO)))
		a100Imprime(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE,STR0010) //"Tipo invalido"
	End
	If Empty(E2_VALOR) .or. Empty(E2_VLCRUZ)
		a100Imprime(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE,STR0050) //"Valor nao preenchido"
	End
	If Empty(E2_NATUREZ) .or. !(SED->(dbSeek(xFilial("SED")+SE2->E2_NATUREZ)))
		a100Imprime(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE,STR0051) //"Natureza Invalida"
	End
	If Empty(E2_BAIXA) .and. NoRound(SE2->E2_SALDO,2) != NoRound(SE2->E2_VALOR,2)
		a100Imprime(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE,STR0052) //"Valores Orig/Saldo Incompativeis"
	End
	If NoRound(SE2->E2_SALDO,2) > NoRound(SE2->E2_VALOR,2)
		a100Imprime(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE,STR0052) //"Valores Orig/Saldo Incompativeis"
	End
	If !(SA2->(dbSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA)))
		a100Imprime(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE,STR0026) //"Cliente nao cadastrado"
	End
	dbSkip( )
End

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CheckSi1  ³ Autor ³ Wagner/Wilson Jr      ³ Data ³ 14/09/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Checagem do Cadastro de Plano de Contas.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CheckSi1( )                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SigaMan Advanced.                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CheckSI1()
LOCAL nReg
PRIVATE cAliasAtu := "SI1"
dbSelectArea("SI1")
dbSeek( cFilial )
SetRegua(RecCount())

While !Eof( ) .and. I1_FILIAL == cFilial
	
	IncRegua()
	a100CheckDup( "I1_CODIGO" )
	
	If Empty( I1_DESC )
		a100Imprime(I1_CODIGO,STR0016) //"Descricao nao Preenchida"
	End
	
	If !( I1_CLASSE $"AS" )
		a100Imprime(I1_CODIGO,STR0053) //"Classe Invalida"
	End
	
	If Val(I1_NIVEL) = 0
		a100Imprime(I1_CODIGO,STR0054) //"Nivel Invalido"
	End
	
	If !( I1_NORMAL $"DC" )
		a100Imprime(I1_CODIGO,STR0055) //"Condicao Invalida"
	End
	
	nReg := Recno()
	
	IF !Empty(I1_CTAVM) .and. !(SI1->(dbSeek(xFilial("SI1")+I1_CTAVM)))
		a100Imprime(I1_CODIGO,STR0056) //"Conta Variacao Invalida"
	End
	dbGoto(nReg)
	IF !Empty(SI1->I1_CC) .and. !(SI3->(dbSeek(xFilial("SI3")+SI1->I1_CC)))
		a100Imprime(SI1->I1_CODIGO,STR0057) //"Centro de Custo Invalido"
	End
	dbSelectArea( "SI1" )
	dbSkip( )
End

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CheckSi2  ³ Autor ³ Wagner/Wilson Jr      ³ Data ³ 14/09/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Checagem do Cadastro de Lancamentos.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CheckSi2( )                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SigaMan Advanced.                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CheckSI2()
PRIVATE cAliasAtu := "SI2"
dbSelectArea("SI2")
dbSetOrder(3)
dbSeek( cFilial )
SetRegua(RecCount())

While !Eof( ) .and. I2_FILIAL == cFilial
	
	IncRegua()
	a100CheckDup( "DTOS(I2_DATA)+I2_NUM+I2_LINHA" )
	
	If Empty( I2_NUM ) .or. Empty( I2_LINHA) .or.  Empty( I2_DATA )
		a100Imprime(DTOC(I2_DATA)+I2_NUM+I2_LINHA,STR0058) //"Numero Identificacao Invalido"
	End
	If Empty( I2_PERIODO )
		a100Imprime(DTOC(I2_DATA)+I2_NUM+I2_LINHA,STR0059) //"Periodo nao preenchido"
	End
	If Empty( I2_VALOR ) .and. SubStr(SI2->I2_MOEDAS,1,1)=="S" .And. I2_DC != "-"
		a100Imprime(DTOC(I2_DATA)+I2_NUM+I2_LINHA,STR0050) //"Valor nao preenchido"
	End
	If !(I2_DC$"DCX-")
		a100Imprime(DTOC(I2_DATA)+I2_NUM+I2_LINHA,STR0060) //"Tipo D/C/X Invalido"
	End
	IF I2_DC$"DX" .and. !(SI1->(dbSeek(xFilial("SI1")+SI2->I2_DEBITO)))
		a100Imprime(DTOC(I2_DATA)+I2_NUM+I2_LINHA,STR0061) //"Conta Debito invalida"
	Elseif I2_DC$"DX" .and. SI1->I1_CLASSE != "A"
		a100Imprime(DTOC(I2_DATA)+I2_NUM+I2_LINHA,STR0062) //"Conta Debito nao Analitica"
	End
	
	IF I2_DC$"CX" .and. !(SI1->(dbSeek(xFilial("SI1")+SI2->I2_CREDITO)))
		a100Imprime(DTOC(I2_DATA)+I2_NUM+I2_LINHA,STR0063) //"Conta Credito Invalida"
	Elseif I2_DC$"CX" .and. SI1->I1_CLASSE != "A"
		a100Imprime(DTOC(I2_DATA)+I2_NUM+I2_LINHA,STR0064) //"Conta Credito nao Analitica"
	Endif
	
	If Empty( I2_MOEDAS )
		a100Imprime(DTOC(I2_DATA)+I2_NUM+I2_LINHA,STR0065) //"Ident.Moedas nao preenchido"
	End
	
	dbSkip()
End
Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CheckSi3  ³ Autor ³ Wagner/Wilson Jr      ³ Data ³ 14/09/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Checagem do Cadastro de Centro de Custos.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CheckSi3( )                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SigaMan Advanced.                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CheckSI3()
PRIVATE cAliasAtu := "SI3"
dbSelectArea("SI3")
dbSeek( cFilial )
SetRegua(RecCount())

While !Eof( ) .and. I3_FILIAL == cFilial
	
	IncRegua()
	a100CheckDup( "I3_CUSTO+I3_CONTA+I3_MOEDA" )
	dbSkip()
End

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CheckSn1  ³ Autor ³ Wagner/Wilson Jr      ³ Data ³ 14/09/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Checagem do Cadastro de Bens do Ativo Fixo.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CheckSn1( )                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SigaMan Advanced.                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CheckSn1()
PRIVATE cAliasAtu := "SN1"
dbSelectArea("SN1")
dbSeek( cFilial )
SetRegua(RecCount())

While !Eof( ) .and. N1_FILIAL == cFilial
	
	IncRegua()
	a100CheckDup( "N1_CBASE+N1_ITEM" )
	
	If Empty( N1_AQUISIC )
		a100Imprime(N1_CBASE+N1_ITEM,STR0066) //"Data Aquisicao nao preenchida"
	End
	
	If Empty( N1_DESCRIC )
		a100Imprime(N1_CBASE+N1_ITEM,STR0016) //"Descricao nao preenchida"
	End
	dbSkip()
End

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CheckSn3  ³ Autor ³ Wagner/Wilson Jr      ³ Data ³ 14/09/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Checagem do Cadastro de Contas / Valores do Ativo.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CheckSn3( )                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SigaMan Advanced.                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CheckSn3()
Local ni,cConta
Local aContas := {"N3_CCONTAB","N3_CCORREC","N3_CDEPREC","N3_CDESP","N3_CCDEPR"}
PRIVATE cAliasAtu := "SN3"
dbSelectArea("SN3")
dbSeek( cFilial )
SetRegua(RecCount())

While !Eof( ) .and. N3_FILIAL == cFilial
	
	IncRegua()
	If !(N3_TIPO$"01/02/03/04")
		a100Imprime(N3_CBASE+N3_ITEM+N3_TIPO,STR0010) //"Tipo Invalido"
	End
	
	If !Empty( N3_TXDEPR1 ) .and. Empty(N3_DINDEPR)
		a100Imprime(N1_CBASE+N1_ITEM,STR0067) //"Data Depreciacao nao preenchida"
	End
	
	dbSkip( )
	
	For ni := 1 to Len(aContas)
		cConta := &(aContas[ni])
		IF !Empty(cConta)
			dbSelectArea("SX3")
			dbSetOrder(2)
			dbSeek(aContas[ni])
			dbSetOrder(1)
			dbSelectArea("SN3")
			IF !(SI1->(dbSeek(xFilial("SI1")+cConta)))
				a100Imprime(N1_CBASE+N1_ITEM,SX3->X3_DESCRIC+ STR0067) //" nao cadastrada"
			Else
				IF SI1->I1_CLASSE != "A"
					a100Imprime(N1_CBASE+N1_ITEM,SX3->X3_DESCRIC+ STR0068) //" Sintetica"
				End
			Endif
		Endif
	Next
End

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³a100CheckD³ Autor ³ Wagner/Wilson Jr      ³ Data ³ 14/09/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Checagem do Cadastro de Lancamentos.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CheckSi2( )                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SigaMan Advanced.                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function A100CheckDup(cChave)
Local cAlias:=Alias(),cCalcFil:=Subs(cAliasAtu,2,2)+"_FILIAL+",cChaveATu,cChaveProx
dbSelectArea(cAliasAtu)
nReg := StrZero(Recno(),6)
cChave := cCalcFil+cChave
cChaveAtu := &cChave
cChaveProx:="XXXXX"
dbSkip()
IF !Eof()
	cChaveProx:=&cChave
	nRegProx := Strzero(Recno(),6)
Endif
IF cChaveProx == cChaveAtu
	a100Imprime(cChaveProx,STR0069+nReg+STR0070+nRegProx) //"Registro "   " Igual a "
Endif
dbGoto(Val(nReg))
dbSelectArea(cAlias)
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³a100Imprim³ Autor ³ Wagner/Wilson Jr      ³ Data ³ 14/09/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Checagem do Cadastro de Lancamentos.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³a100Imprime()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SigaMan Advanced.                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function A100Imprime(cAccess,cMensagem)
Local titulo:=STR0001 //"Checagem da Integridade dos arquivos Advanced"
Local cabec1:=STR0071 //"Arq Descricao                      Endereco     Chave Principal de Acesso     N.Reg. Mensagem"
Local cabec2:=""
Local cAlias:= Alias()
Local nReg  := StrZero(Recno(),6)
Local nomeprog:="MANA100"
dbSelectArea("SX2")
dbSeek(cAliasAtu)
IF Li > 50
	cabec(titulo,cabec1,cabec2,nomeprog,"M",18)
End
@li,000 PSay cAliasAtu
@li,004 PSay FWX2Nome(cAliasAtu)
@li,035 PSay RetSQLName(cAliasAtu)
@li,048 PSay SubStr(cAccess,1,30)
@li,078 PSay nReg	Picture "999999"
@li,085 PSay SubStr(cMensagem,1,46)
li++
dbSelectArea( cAlias )
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³a100Arqs  ³ Autor ³ Wagner/Wilson Jr      ³ Data ³ 14/09/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Trata achoice para escolha dos arquivos a serem checados.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³a100Arqs()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SigaMan Advanced.                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function a100Arqs(nModo,nPos,nRelPos)
LOCAL nTecla   := Lastkey()
LOCAL nRetCode := 2
IF nModo = 3
	IF nTecla = 19 .Or. nTecla = 4
		nRetCode := 2
	Elseif nTecla = 13
		IF SubStr(aArquivos[nPos],37,1) = "x"
			aArquivos[nPos] := SubStr(aArquivos[nPos],1,36)+" ]"
		Else
			aArquivos[nPos]:= SubStr(aArquivos[nPos],1,36)+"x]"
		End
	ELSEIF nTecla = K_ESC
		lContinua := .F.
		nRetCode := 0
	End
Elseif nModo = 2
	lContinua := .F.
	nRetCode  := 2
End
Return nRetCode

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CheckSl1 ³ Autor ³ Andre Veiga           ³ Data ³ 30.11.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Checagem do cadastro de orcamentos                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CheckSl1()  		                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CheckSl1()
Local lDup
cAliasAtu := "SL1"

dbSelectArea("SL1")
dbSetOrder(1)
dbSeek(xFilial("SL1"))
SetRegua(RecCount())

SL2->(dbSetOrder(1))
SF2->(dbSetOrder(1))
SF4->(dbSetOrder(1))
SE1->(dbSetOrder(1))
SD2->(dbSetOrder(3))
SL4->(dbSetOrder(1))

While !Eof() .And. SL1->L1_FILIAL == xFilial("SL1")
	IncRegua()
	lDup := .F.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Checa se os itens do orcamento estao gravados                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !(SL2->(dbSeek(xFilial("SL2")+SL1->L1_NUM)))
		a100Imprime(SL1->L1_NUM,STR0072) //"Orcamento sem Item"
	Else
		If !Empty(SL1->L1_DOC)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Checa se os existe titulo para essa venda                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SL2")
			lDup := .F.
			While !Eof() .And. xFilial("SL2")+SL1->L1_NUM==SL2->L2_FILIAL+SL2->L2_NUM .And. lDup == .F.
				If Posicione("SF4",1,xFilial("SF4")+SL2->L2_TES,"F4_DUPLIC") == "S"
					lDup := .T.
				Endif
				dbSkip()
			Enddo
			dbSelectArea("SL1")
			If lDup
				If !(SE1->(dbSeek(xFilial("SE1")+SL1->L1_SERIE+SL1->L1_DOC)))
					a100Imprime(SL1->L1_NUM,STR0073+SL1->L1_DOC ) // "Orcamento vendido sem Titulo No."
				Endif
			Endif
		Endif
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Checa se existe nota fiscal para o orcamento                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(SL1->L1_DOC)
		If !(SF2->(dbSeek(xFilial("SF2")+SL1->L1_DOC+SL1->L1_SERIE)))
			a100Imprime(SL1->L1_NUM,STR0074+SL1->L1_DOC) // "Orcamento vendido sem Nota Fiscal No."
		Endif
		If !(SD2->(dbSeek(xFilial("SD2")+SL1->L1_DOC+SL1->L1_SERIE)))
			a100Imprime(SL1->L1_NUM,STR0075+SL1->L1_DOC) //"Orcamento vendido sem Iten de Nota Fiscal No."
		Endif
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Checa o cadastro de formas de pagamento                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !(SL4->(dbSeek(xFilial("SL4")+SL1->L1_NUM)))
		a100Imprime(SL1->L1_NUM,STR0076)
	Endif
	
	dbSkip()
Enddo

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MANA100a  ºAutor  ³Andre Veiga         º Data ³  04/12/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta a tela para selecionar os arquivos.                   º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Mana100a(aArquivos)
dbSelectArea( "SX2" )
dbGoTop()
While !Eof()
	If (FWX2CHAVE() $ "SA1üSA2üSA3üSA6üSB1üSB2üSB9üSC1üSC2üSC5üSC6üSC7üSD4üSE1üSE2üSG1üSG2üSI1üSI2üSI3üSL1üSN1üSN3")
		aAdd( aArquivos, { .T., FWX2CHAVE(), Subst( FWX2Nome( FWX2CHAVE() ),1,30)} )
	End
	dbSkip( )
End

DEFINE MSDIALOG oDlg2 TITLE STR0077 FROM 0,0 TO 270,460 PIXEL // "Selecione os arquivos"
oOk := LoadBitmap( GetResources(), "LBOK" )
oNo := LoadBitmap( GetResources(), "LBNO" )

@10,10 LISTBOX oAcesso FIELDS HEADER "",STR0078,STR0079 FIELDSIZES 14,25,15 SIZE 210,100 PIXEL //"Alias"      "Descrição do Arquivo"
oAcesso:SetArray(aArquivos)
oAcesso:bLine := { || {If(aArquivos[oAcesso:nAt,1],oOk,oNo),aArquivos[oAcesso:nAt,2],aArquivos[oAcesso:nAt,3]}}
oAcesso:bLDblClick := {|| aArquivos[oAcesso:nAt,1] := !aArquivos[oAcesso:nAt,1],oAcesso:DrawSelect(),;
lAllacesso:=.T.,aeval(aArquivos,{|aLinha| lAllAcesso:=if(lAllAcesso.and.aLinha[1],.t.,.F.) }),oAcesso:Refresh()}

DEFINE SBUTTON FROM	120,168 TYPE 1 ENABLE OF oDlg2 ACTION (lRet:=.T.,oDlg2:End())
DEFINE SBUTTON FROM 120,197 TYPE 2 ENABLE OF oDlg2 ACTION (lRet:=.F.,oDlg2:End())
ACTIVATE DIALOG oDlg2 CENTERED

Return lRet
