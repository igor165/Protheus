#include "Protheus.ch"
#include "MDTR821.ch"

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTR821
Relat�rio de impress�o EPI x Tarefa

@author Guilherme Benkendorf
@since 29/01/14
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Function MDTR821()

//-------------------------------------------------
// Armazena variaveis p/ devolucao (NGRIGHTCLICK)
//-------------------------------------------------
Local aNGBEGINPRM := NGBEGINPRM()

Local oReport
Local aArea := GetArea()

Private cPerg  := PADR( "MDTR821" , 10 )

If TRepInUse()
   //-- Interface de impressao
  	oReport := ReportDef(cPerg)
	oReport:SetPortrait()
	oReport:PrintDialog()
Else
   MDTR821IMP()
EndIf

RestArea(aArea)

//----------------------------------------------
// Devolve variaveis armazenadas (NGRIGHTCLICK)
//----------------------------------------------
NGRETURNPRM(aNGBEGINPRM)

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MDTR821
Relat�rio de impress�o EPI x Tarefa

@author Guilherme Benkendorf
@since 29/01/14
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function ReportDef( cPerg )

Static oReport
Static oSection1
Static oSection2
Static oCell

oReport := TReport():New(cPerg , OemToAnsi(STR0001),cPerg,{ | oReport | ReportPrint()})  //"EPI x Tarefa"

/*-------------------------------------
//PADR�O									|
|  mv_par01		De Tarefa ?			|
|  mv_par02		At� Tarefa ?			|
|  mv_par03		De EPI ?				|
|  mv_par04       At� EPI ?				|
---------------------------------------*/

Pergunte(oReport:uParam,.F.)

Return oReport
//---------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
Impress�o do modo personalizado

@author Guilherme Benkendorf
@since 29/01/14
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function ReportPrint()
Local cTarefa := ""
Local lImpTIK := .F.

MDT821SEC()

dbSelectArea("TIK")
dbSetOrder(01)//TIK_FILIAL+TIK_TAREFA+TIK_EPI
dbSeek(xFilial("TIK")+MV_PAR01,.t.)

While !Eof() .AND. !oReport:Cancel()                 .And.;
							 TIK->TIK_FILIAL == xFIlial("TIK") .And.;
							 TIK->TIK_TAREFA >= MV_PAR01       .And.;
							 TIK->TIK_TAREFA <= MV_PAR02

	If TIK->TIK_EPI < MV_PAR03 .Or. TIK->TIK_EPI > MV_PAR04
		dbSelectArea( "TIK" )
  		DbSkip()
  		Loop
	EndIf

	If cTarefa <> TIK->TIK_TAREFA

		If !Empty( cTarefa )
   		oSection2:Finish()
   		oSection1:Finish()
  		EndIf

		cTarefa := TIK->TIK_TAREFA

		oSection1:Init()
		oSection1:PrintLine()
		oSection2:Init()
	EndIf

	oSection2:PrintLine()

	dbSelectArea( "TIK" )
	DbSkip()

	lImpTIK:= .T.
End

If lImpTIK
	oSection2:Finish()
	oSection1:Finish()
Else
	MsgInfo( STR0002 ) //"N�o h� dados a serem impressos."
	Return .F.
EndIf

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT821SEC

Monta a estrutura da impress�o personalizada (TReport).

@author Guilherme Benkendorf
@since 29/01/14
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function MDT821SEC()

oReport:Asection := {}  //Apaga as secoes dos parametros anteriores

	oReport:SetTotalInLine(.F.)

	//Secao 1 - Tarefa
	oSection1 := TRSection():New(oReport,STR0001, {"TIK", "TN5"} )
	oSection1:SetHeaderBreak() // sempre que houver quebra imprime o cabe�alho da se��o
	oCell := TRCell():New (oSection1, "TIK_TAREFA"  , "TIK", STR0003, "@!", Len(TIK->TIK_TAREFA)+5, /*lPixel*/, /*{|| code-block de impressao }*/) //"C�digo da Tarefa"
	TRPosition():New(oSection1,"TN5",1,"xFilial('TN5')+TIK->TIK_TAREFA")
	oCell := TRCell():New (oSection1, "TN5_NOMTAR" , "TN5", STR0004, "@!", 130, /*lPixel*/, /*{|| code-block de impressao }*/) //"Descri��o da Tarefa"
	//Secao 2 - EPI
	oSection2 := TRSection():New(oReport,STR0005 , {"TIK", "SB1"} ) //"EPI"
	oCell := TRCell():New(oSection2, "TIK_EPI"  , "TIK", STR0006, "@!", Len(TIK->TIK_EPI)+1)  //"C�digo do EPI"
	//Posicionamento no SB1 para a descri��o do EPI
	TRPosition():New(oSection2, "SB1", 1, "xFilial('SB1')+TIK->TIK_EPI")
	oCell := TRCell():New(oSection2, "B1_DESC"  , "SB1", STR0007, "@!", Len(SB1->B1_DESC))  //"Descri��o do EPI"

	oSection1:Cell("TN5_NOMTAR"):lLineBreak := .T.

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MDTR821IMP
Monta cabe�alho para impressao do relatorio padr�o.

@author Guilherme Benkendorf
@since 29/01/14
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function MDTR821IMP()

//------------------
// Define Variaveis
//------------------
Local cString := "TIK"
Local wnrel   := "MDTR821"
Local cDesc1  := STR0008 //"Relatorio de apresentacao dos EPI relacionados "
Local cDesc2  := STR0009 //"a Tarefa."
Local cDesc3  := " "


Private aReturn  := { STR0010, 1 ,STR0011, 2, 2, 1, "",1 } //"Zebrado"###"Administracao"
Private nomeprog := "MDTR821"
Private tamanho  := "M"
Private titulo   := STR0001//"EPI x Tarefa"
Private ntipo    := 0
Private nLastKey := 0
Private cabec1, cabec2

//-------------------------------------
// Verifica as perguntas selecionadas
//-------------------------------------
Pergunte(cPerg,.F.)

//-----------------------------------------
/*/
// Variaveis utilizadas para parametros
// mv_par01             // De EPI ?
// mv_par02             // At� EPI ?
/*/
//-----------------------------------------

wnrel:=SetPrint(cString,wnrel,cPerg,titulo,cDesc1,cDesc2,cDesc3,.F.,"")

If nLastKey == 27
	Set Filter to
	Return Nil
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Set Filter to
   Return
Endif

Processa( {|lEnd| R821Imp(@lEnd,wnRel,titulo,tamanho)}, STR0012 ,STR0013 ) //"Aguarde" ## "Processando os EPI e Tarefas..."

Return NIL
//---------------------------------------------------------------------
/*/{Protheus.doc} R821Imp
Impressao do relat�rio padrao MDTR821.

@author Guilherme Benkendorf
@since 29/01/14
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function R821Imp(lEnd,wnRel,titulo,tamanho)
Local nLin:= 0
Local nLinVal := 0
Local cTarefa := ""
Local lImpTIK := .F.
//-------------------------------
// Contadores de linha e pagina
//-------------------------------
PRIVATE li := 80 ,m_pag := 1

//----------------------------------------------
//  Tratativa de descri��o da TN5 - Tarefas
//----------------------------------------------
cDescTN5 := "Alltrim(TN5->TN5_NOMTAR)"


//-------------------------------------
//  Verifica se deve comprimir ou nao
//-------------------------------------
nTipo  := IIF(aReturn[4]==1,15,18)

//----------------------
//  Monta os Cabecalhos
//----------------------
cabec1 := STR0014//"C�digo da Tarefa    Descri��o da Tarefa"
cabec2 := STR0015//"     C�digo do EPI                      Descri��o do EPI"

/*
Classificar por EPI

          1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2
01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
C�digo da Tarefa    Descri��o da Tarefa
     C�digo do EPI                      Descri��o do EPI
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
xxxxxx              xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
     xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx     xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*/

dbSelectArea("TIK")
dbSetOrder(01)//TIK_FILIAL+TIK_TAREFA+TIK_EPI
dbSeek(xFilial("TIK")+MV_PAR01,.t.)
While !Eof() .AND. TIK->TIK_FILIAL == xFIlial("TIK") .And.;
					TIK->TIK_TAREFA >= MV_PAR01                .And.;
					TIK->TIK_TAREFA <= MV_PAR02

	If TIK->TIK_EPI < MV_PAR03 .Or. TIK->TIK_EPI > MV_PAR04
		dbSelectArea("TIK")
		dbSkip()
		Loop
	EndIf

	If cTarefa <> TIK->TIK_TAREFA
		cTarefa := TIK->TIK_TAREFA

		Somalinha()
		@ Li,000 PSay TIK->TIK_TAREFA Picture "@!"

		dbSelectArea("TN5")
		dbSetOrder( 1 )
		dbSeek( xFilial( "TN5" ) + cTarefa )
		cDescTar := &(cDescTN5)
		nLinVal  := MlCount( cDescTar,105 )

		For nLin := 1 To nLinVal

			@ Li,020 Psay MemoLine( cDescTar ,105,nLin)
			SomaLinha()

		Next nLin
	EndIf

	@ Li,005 PSay TIK->TIK_EPI Picture "@!"
	@ Li,040 PSay NGSeek( "SB1", TIK->TIK_EPI, 1 , "B1_DESC") Picture "@!"
	Somalinha()

	dbSelectArea("TIK")
	dbskip()
	lImpTIK := .T.
End

//----------------------------------------------------
//  Devolve a condicao original do arquivo principal
//----------------------------------------------------

Set Filter To

Set device to Screen

If aReturn[5] = 1
	Set Printer To
	dbCommitAll()
	If !lImpTIK
		MsgInfo( STR0016 ) //"N�o h� dados a serem impressos."
		//SET CENTURY ON
		MS_FLUSH()
		Return .F.
	EndIf
	OurSpool(wnrel)
Endif

//SET CENTURY ON
MS_FLUSH()

Return Nil
//---------------------------------------------------------------------
/*/{Protheus.doc} Somalinha

@author
@since
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function Somalinha()
    Li++
    If Li > 58
        Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
    EndIf
Return
//---------------------------------------------------------------------
/*/{Protheus.doc} fDescTN5

Concatena descri��es da tabela TN5 - Tarefas

fDescTN5(TN5->TN5_DESTAR , TN5->TN5_DESCR1 , TN5->TN5_DESCR2 , ;
			 TN5->TN5_DESCR3 , TN5->TN5_DESCR4)

@author Guilherme Benkendorf
@since 30/01/14
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function fDescTN5( cDescri, cDescr1, cDescr2, cDescr3, cDescr4 )
Local cDescricao := ""

If !Empty(cDescri)
	cDescricao += Alltrim(cDescri) + " "
EndIf

If !Empty(cDescr1)
	cDescricao += Alltrim(cDescr1) + " "
EndIf

If !Empty(cDescr2)
	cDescricao += Alltrim(cDescr2) + " "
EndIf

If !Empty(cDescr3)
	cDescricao += Alltrim(cDescr3) + " "
EndIf

If !Empty(cDescr4)
	cDescricao += Alltrim(cDescr4) + " "
EndIf

Return cDescricao

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTR821VAL

Fun��o de valida��o para o grupo (X1_GRUPO) MDTR821
@param nPar - n�mero da varivel a ser verificada.
@author Guilherme Benkendorf
@since 30/01/14
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Function MDTR821VAL( nPar )
Local lRet := .T.

//Verifica a existencia do parametro na TN5
If nPar == 1
	lRet := If(!Empty( MV_PAR01 ), ExistCpo( 'TN5', MV_PAR01, 1 ), .T. )
EndIf

//Se n�o for ultima posi��o verifica a existencia do parametro na TN5
If nPar == 2
	If MV_PAR02 <> Replicate("Z",Len(MV_PAR02))
		lRet := If(!Empty( MV_PAR02 ), ExistCpo( 'TN5', MV_PAR02, 1 ), .T. )
	EndIf
EndIf

//Verifica a existencia do parametro na SB1
If nPar == 3
	lRet := If(!Empty( MV_PAR03 ), ExistCpo( 'SB1', MV_PAR03, 1 ), .T. )
EndIf
//Se n�o for ultima posi��o verifica a existencia do parametro na SB1
If nPar == 4
	If MV_PAR04 <> Replicate("Z",Len(MV_PAR04))
		lRet := If(!Empty( MV_PAR04 ), ExistCpo( 'SB1', MV_PAR04, 1 ), .T. )
	EndIf
EndIf

//----------------------------------------
// Verifica os parametros De/Ate c�digo.
//----------------------------------------
If nPar == 1 .Or. nPar == 2
	If Empty(MV_PAR01) .And. MV_PAR02 == Replicate("Z",Len(MV_PAR02))
		lRet := If(lRet, AteCodigo("TN5",MV_PAR01,MV_PAR02,Len(MV_PAR02) ) ,lRet)
	EndIf
EndIf

If nPar == 3 .Or. nPar == 4
	If Empty(MV_PAR03) .And. MV_PAR04 == Replicate("Z",Len(MV_PAR04))
		lRet := If(lRet, AteCodigo("SB1",MV_PAR03,MV_PAR04,Len(MV_PAR03) ) ,lRet)
	EndIf
EndIf

Return lRet