#INCLUDE "SGAA490.ch"
#include "protheus.ch"

#DEFINE _nVERSAO 2

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SGAA490   �Autor  �Roger Rodrigues     � Data �  21/02/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina para cadastro de Pontos de Coleta					  ���
���          �															  ���
�������������������������������������������������������������������������͹��
���Uso       �SIGASGA                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function SGAA490()
Local aNGBEGINPRM := NGBEGINPRM(_nVERSAO)
Local oTempTRB
Local aField := {}

Private aRotina := MenuDef()
Private cCadastro := OemtoAnsi(STR0001) //"Pontos de Coleta"

//Alias da TRB para montagem do browse
Private cAliasTDB

//Verifica se o Update de FMR esta aplicado
If !SGAUPDFMR() .Or. !VrfComp490()
	Return .F.
EndIf

cAliasTDB := GetNextAlias()
dbSelectarea("TDB")
dbSetorder(1)
                                     
//Filtro utilizado para montar mBrowse 
fLoadFiltro(@oTempTRB)

//Endereca a funcao de BROWSE
aField := {	{ STR0002 , "TDB_DEPTO" 	, "C" , 3	, 0 , "999"},;	//"Localiza��o"
				{ STR0003 , "TDB_DESDEP"	, "C" , 56	, 0 , "@!" }}		//"Descri��o"

mBrowse(6,1,22,75,(cAliasTDB),aField)

oTempTRB:Delete()

//Devolve variaveis armazenadas (NGRIGHTCLICK)
NGRETURNPRM(aNGBEGINPRM)

Return .T.
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SGA490ALT �Autor  �Roger Rodrigues     � Data �  21/02/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Monta tela para cadastro de pontos de coleta                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SGAA490                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function SGA490ALT(cAlias,nRecno,nOpcx)

	Local oDlg490, oPanelTop,oPnlPai
	Local lOk := .T.
	Local nCpoFlt, j, nPos
	Local cGetWhlPt := ""
	Local lRet := .F.   
	Local lFound, nExiste
	Local nPosCod

	Private nLinhas := 0
	Private cTitulo := STR0001//"Pontos de Coleta"
	Private cDepto  := Space(Len(TAF->TAF_CODNIV))
	Private cDesc   := Space(Len(TAF->TAF_NOMNIV))

	//Variaveis de tamanho de tela e objetos
	Private aSize := MsAdvSize(,.f.,430), aObjects := {}
	Aadd(aObjects,{050,050,.t.,.t.})
	Aadd(aObjects,{100,100,.t.,.t.})
	aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
	aPosObj := MsObjSize(aInfo, aObjects,.t.)

	Inclui := (nOpcx == 3)
	Altera := (nOpcx == 4)

	//Utiliza TRB caso esteja acessando a rotina em si	
	If IsInCallStack("SGAA490")
		dbSelectArea("TDB")   
		dbSetOrder(1)
		dbSeek(xFilial("TDB")+(cAliasTDB)->TDB_DEPTO)                        
	EndIf

	If Altera .Or. nOpcx == 5 .Or. nOpcx == 2
		cDepto := TDB->TDB_DEPTO
		cDesc  := NGSEEK("TAF",cDepto,8,"TAF->TAF_NOMNIV")
	Endif

	Define MsDialog oDlg490 Title cTitulo From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd Pixel

		//Panel criado para correta disposicao da tela
		oPnlPai := TPanel():New( , , , oDlg490 , , , , , , , , .F. , .F. )
			oPnlPai:Align := CONTROL_ALIGN_ALLCLIENT

		oPanelTop := TPanel():New(0,0,,oPnlPai,,,,,,0,aPosObj[1,4],.F.,.F.)
			oPanelTop:Align := CONTROL_ALIGN_TOP

		@ 0.5,0.3 Say OemtoAnsi(STR0002) Color CLR_BLUE Size 50,08 Of oPanelTop //"Localiza��o"
		@ 0.3,5.3 MsGet cDepto Size 020,10 Of oPanelTop VALID SG490VLDEP(cDepto) Picture "@!" F3 "SGATAF" WHEN Inclui HASBUTTON

		@ 0.5,19 Say OemtoAnsi(STR0003) Color CLR_BLACK Size 45,08 Of oPanelTop //"Descri��o"
		@ 0.3,23 MsGet cDesc Size 130,10 Of oPanelTop When .F.

		aCols := {}
		aHeader := {}

		cGetWhlPt := "TDB->TDB_FILIAL == '"+xFilial("TDB")+"' .AND. TDB->TDB_DEPTO = '"+cDepto+"'"
		FillGetDados( nOpcx, "TDB", 1, cDepto, {|| }, {|| .T.},{"TDB_DEPTO"},,,,{|| NGMontaAcols("TDB", cDepto,cGetWhlPt)})

		If Empty(aCols) .Or. nOpcx == 3
		   aCols := BlankGetd(aHeader)
		Endif
		nLinhas := Len(aCols)
		dbSelectArea("TDB")
		oGet490 := MsNewGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],IIF(!Inclui.And.!Altera,0,GD_INSERT+GD_UPDATE+GD_DELETE),"SGA490LOK()",,,,,9999,,,"SGA490DEL()",oPnlPai,aHeader, aCols)
		oGet490:oBrowse:Default()
		oGet490:oBrowse:Refresh()
		oGet490:oBrowse:Align := CONTROL_ALIGN_BOTTOM

	Activate Dialog oDlg490 On Init (EnchoiceBar(oDlg490,{|| lOk:=.T.,If(SGA490TOK(nOpcx),oDlg490:End(),lOk := .f.)},{|| lOk:= .F.,oDlg490:End()})) Centered

	If lOk

		aCols	:= oGet490:aCols
		aHeader := oGet490:aHeader  
		nPosCod := aScan(aHeader, {|x| Trim(Upper(x[2])) == "TDB_CODIGO"})
		
		If Inclui .or. Altera
		
			//Exclui registro da Base, caso n�o esteja na GetDados
			dbSelectArea("TDB")
			dbSetOrder(1)
			dbSeek(xFilial("TDB")+cDepto)
			While(!Eof() .And. xFilial("TDB") == TDB->TDB_FILIAL .And. TDB->TDB_DEPTO == cDepto)
			
				If aScan( aCols, { |x| x[nPosCod] == TDB->TDB_CODIGO }) == 0
					Reclock("TDB", .F.)
					dbDelete()
					MsUnLock("TDB")
				EndIf
				dbSkip()	
			
			EndDo

			For nCpoFlt:=1 to Len(aCols)
				If !aCols[nCpoFlt][Len(aCols[nCpoFlt])] .and. !Empty(aCols[nCpoFlt][nPosCod])
					dbSelectArea("TDB")
					dbSetOrder(1)
					lFound := dbSeek(xFilial("TDB")+cDepto+aCols[nCpoFlt][nPosCod])

					RecLock("TDB",!lFound)
						
					For j:=1 to FCount()
						If "_FILIAL"$Upper(FieldName(j))
							FieldPut(j, xFilial("TDB"))
						ElseIf "_DEPTO"$Upper(FieldName(j))
							FieldPut(j, cDepto)
						ElseIf "_CODIGO"$Upper(FieldName(j))
							FieldPut(j, aCols[nCpoFlt][nPosCod])
						ElseIf (nPos := aScan(aHeader, {|x| Trim(Upper(x[2])) == Trim(Upper(FieldName(j))) }) ) > 0
							FieldPut(j, aCols[nCpoFlt][nPos])
						Endif
					Next j
					MsUnlock("TDB")
				ElseIf !Empty(aCols[nCpoFlt][nPosCod]) .And. aScan(aCols,{|x| x[nPosCod] == aCols[nCpoFlt][nPosCod] }, nCpoFlt + 1) == 0
					dbSelectArea("TDB")
					dbSetOrder(1)
					If dbSeek(xFilial("TDB")+cDepto+aCols[nCpoFlt][nPosCod])
						RecLock("TDB",.F.)
						dbDelete()
						MsUnlock("TDB")
					Endif
				EndIf   
				
			Next nCpoFlt	
			
			//Inclui registro na TRB
			If Inclui .And. Type("cAliasTDB") == "C" .And. Select(cAliasTDB) > 0
				dbSelectArea("TDB")
				dbSetOrder(1)
				If dbSeek(xFilial("TDB")+cDepto)
					dbSelectArea(cAliasTDB)
					dbSetOrder(1)
					If !dbSeek(cDepto)
						RecLock(cAliasTDB,.T.)
						(cAliasTDB)->TDB_DEPTO := cDepto
						(cAliasTDB)->TDB_DESDEP := cDesc
						MsUnlock(cAliasTDB)
					EndIf
				EndIf
			EndIf
		
		ElseIf nOpcx == 5

			//Deleta registro da base
			For nCpoFlt:=1 to Len(aCols)
				dbSelectArea("TDB")
				dbSetOrder(1)
				If dbSeek(xFilial("TDB")+cDepto+aCols[nCpoFlt][nPosCod])
					RecLock("TDB",.F.)
					dbDelete()
					MsUnlock("TDB")
				Endif
			Next nCpoFlt
		
			//Deleta o registro da tabela temporaria	
			If Type("cAliasTDB") == "C" .and. Select(cAliasTDB) > 0
				dbSelectArea("TDB")
				dbSetOrder(1)
				If !dbSeek(xFilial("TDB")+cDepto)
					dbSelectArea(cAliasTDB)
					dbSetOrder(1)
					If dbSeek(cDepto)
						RecLock(cAliasTDB,.F.)
						dbDelete()
						MsUnlock(cAliasTDB)
					EndIf
				EndIf
			EndIf		
		EndIf
	EndIf            
	
	dbSelectArea("TDB")
	dbSetOrder(1)
	dbSeek(xFilial("TDB")+cDepto)          

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SG490VLDEP�Autor  �Roger Rodrigues     � Data �  21/02/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Valida a Localiza��o digitada                               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SGAA490                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function SG490VLDEP(cDepto)
dbSelectArea("TAF")
dbSetOrder(8)
If dbSeek(xFilial("TAF")+cDepto)
	cDesc := TAF->TAF_NOMNIV
	dbSelectArea("TDB")
	dbSetOrder(1)
	If dbSeek(xFilial("TDB")+cDepto)
	   Help(" ",1,"JAEXISTINF")
	   cDesc := Space(Len(TAF->TAF_NOMNIV))
	   Return .F.
	Endif
Else
	Help(" ",1,"REGNOIS")
	Return .F.
Endif

Return .T.
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SGA490LOK �Autor  �Roger Rodrigues     � Data �  21/02/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Valida se a linha da GetDados est� OK                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SGAA490                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function SGA490LOK(lFim)
Local aCols := oGet490:aCols
Local aHeader := oGet490:aHeader
Local n := oGet490:nAt
Local f
Local nPosCod := aSCAN( aHeader, { |x| Trim( Upper(x[2]) ) == "TDB_CODIGO"})
Local nPosDes := aSCAN( aHeader, { |x| Trim( Upper(x[2]) ) == "TDB_DESCRI"})
Default lFim := .F.

//Percorre aCols
For f = 1 to Len(aCols)
	If !aCols[f][Len(aCols[f])]
		If lFim .or. f == n
			//VerIfica se os campos obrigat�rios est�o preenchidos
			If Empty(aCols[f][nPosCod])
				//Mostra mensagem de Help
				Help(1," ","OBRIGAT2",,aHeader[nPosCod][1],3,0)
				Return .F.
			Endif
			If Empty(aCols[f][nPosDes])
				//Mostra mensagem de Help
				Help(1," ","OBRIGAT2",,aHeader[nPosDes][1],3,0)
				Return .F.
			Endif
		Endif
		//Verifica se � somente LinhaOk
		If f <> n .and. !aCols[n][Len(aCols[n])]
			If aCols[f][nPosCod] == aCols[n][nPosCod]
				Help(" ",1,"JAEXISTINF")
				Return .F.
			Endif
		Endif
	Endif
Next f

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SGA490TOK �Autor  �Roger Rodrigues     � Data �  21/02/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Valida GetDados inteira                                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SGAA490                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function SGA490TOK(nOpcx)

Local i
Local nPosCod := GdFieldPos("TDB_CODIGO", oGet490:aHeader)
Local cCodigo
Local lRet := .T. 

If Empty(cDepto)
	//Mostra mensagem de Help
	Help(1," ","OBRIGAT2",,STR0002,3,0) //"Localiza��o"
	Return .F.
Endif

If !SGA490LOK(.T.)
	Return .F.
EndIf

If nOpcx == 5
	dbSelectArea("TDB")
	dbSetOrder(1)
	
	For i := 1 to Len(aCols)
	
		cCodigo := oGet490:aCols[i][nPosCod]
		
		If dbSeek(xFilial("TDB")+cDepto+cCodigo)
			If !NGVALSX9("TDB",,.T.)
				lRet := .F.
				Exit
			EndIf
		EndIf
		
	Next
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SGA490WHEN�Autor  �Roger Rodrigues     � Data �  21/02/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna condi��o de altera��o para campo de C�digo          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SGAA490                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function SGA490WHEN()
Local n := oGet490:nAt
If Altera
	If n > nLinhas
		Return .T.
	Else
		Return .F.
	Endif
Endif

Return .T.
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef  � Autor � Roger Rodrigues       � Data �27/10/2009���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Utilizacao de Menu Funcional.                               ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SigaSGA                                                    ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �	  1 - Pesquisa e Posiciona em um Banco de Dados           ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()
Local aRotina :=	{ { STR0004	, "AxPesqui"	, 0 , 1},; //"Pesquisar"
                      { STR0005	, "SGA490ALT"	, 0 , 2},; //"Visualizar"
                      { STR0006	, "SGA490ALT"	, 0 , 3},; //"Incluir"
                      { STR0007	, "SGA490ALT"	, 0 , 4},; //"Alterar"
                      { STR0008	, "SGA490ALT"	, 0 , 5}} //"Excluir"

Return aRotina

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SGA490SXB �Autor  �Roger Rodrigues     � Data �  21/02/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Chama cadastro na consulta SXB                              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SIGASGA                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function SGA490SXB()

M->TDC_DEPTO := If(Type("M->TDC_DEPTO") <> "C", cDepto490, M->TDC_DEPTO)

If !Empty(M->TDC_DEPTO)
	dbSelectArea("TDB")
	dbSetOrder(1)
	If dbSeek(xFilial("TDB")+M->TDC_DEPTO)
		SGA490ALT("TDB",0,4)
	Else
		SGA490ALT("TDB",0,3)
	Endif
Else
	SGA490ALT("TDB",0,3)
Endif

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} SGALTSXBPT
Filtro para consulta padr�o de pontos de coleta

@author  Gabriel Augusto Werlich
@since   22/07/2014
@version P11
@return
/*/
//---------------------------------------------------------------------
Function SGALTSXBPT()

If Type("cDepto490") == "C"
	Return TDB->TDB_DEPTO == cDepto490
EndIf

Return .F.

//---------------------------------------------------------------------
/*/{Protheus.doc} fLoadFiltro
Carrega um filtro a ser passado para o mBrowse.

@author  Gabriel Augusto Werlich
@since   07/10/2014
@version P11
@return
/*/
//---------------------------------------------------------------------
Static Function fLoadFiltro(oTempTRB)
	Local cQryTDB := ""//
	Local aArea := TDB->(GetArea())
	Local aDBFTDB := {}

	aAdd(aDBFTDB,{ "TDB_DEPTO" , "C" ,03, 0 })
	aAdd(aDBFTDB,{ "TDB_DESDEP" , "C" ,56, 0 })
		
	oTempTRB := FWTemporaryTable():New( cAliasTDB, aDBFTDB )
	oTempTRB:AddIndex( "1", {"TDB_DEPTO"} )
	oTempTRB:Create()
 	
	cQryTDB := " SELECT DISTINCT TDB_FILIAL,TDB_DEPTO, TAF_FILIAL, TAF_CODNIV, TAF_NOMNIV AS TDB_DESDEP "
	cQryTDB += " FROM "+RetSqlName('TDB')+" TDB "
	cQryTDB += " JOIN "+RetSqlName('TAF')+" TAF ON TDB.TDB_DEPTO = TAF.TAF_CODNIV "                          	
	cQryTDB += " AND TAF.TAF_FILIAL = "+ValToSql(xFilial("TAF")) + " "
	cQryTDB += " WHERE TDB_FILIAL = "+ValToSql(xFilial("TDB")) + " "  
	cQryTDB += " AND TDB.D_E_L_E_T_ <> '*'" 
	cQryTDB += " AND TAF.D_E_L_E_T_ <> '*'"
	SqlToTRB(cQryTDB,aDBFTDB,cAliasTDB)
	
	RestArea(aArea)
	
Return Nil
//---------------------------------------------------------------------
/*/{Protheus.doc} ValSX9TDB
Valida��o n�o permite excluir uma linha da getdados caso 
o codigo do ponto de coleta esteja vinculado � outra tabela.

@author  Gabriel Augusto Werlich
@since   07/10/2014
@version P11
@return .T. or .F.
/*/
//---------------------------------------------------------------------
Function SGA490DEL()
	
	Local nPosCod := GdFieldPos("TDB_CODIGO", oGet490:aHeader)
	Local cCodigo := oGet490:aCols[oGet490:nAt][nPosCod]
	
	//Posiciona no registro que est� na linha atual da getdados,
	//para esse registro ser utilizado na fun��o NGVALSX9.
	dbSelectArea("TDB")
	dbSetOrder(1)
	If dbSeek(xFilial("TDB")+cDepto+cCodigo)
		If !NGVALSX9("TDB",,.T.)
			Return .F.
		EndIf
	EndIf
	
Return .T.       
//---------------------------------------------------------------------
/*/{Protheus.doc} VrfComp490()
Valida��o n�o permite excluir uma linha da getdados caso 
o codigo do ponto de coleta esteja vinculado � outra tabela.

@author  Gabriel Augusto Werlich
@since	07/10/2014
@version P11/P12
@return lRet
/*/
//---------------------------------------------------------------------
Static Function VrfComp490()

Local nLevel
Local lRet := .T.

For nLevel := 3 To 1 Step -1
	If FWModeAccess("TAF",nLevel)  == "E" .And. FWModeAccess("TDB",nLevel) == "C"  
		ShowHelpDlg(STR0009,{STR0010, "",STR0011},3,{STR0012})//"Aten��o" ###"O modo de compartilhamento das tabelas TAF e TDB est� incompat�vel."### "A tabela TAF est� em um nivel de compartilhamento exclusivo maior do que da tabela TDB." ###"Altere o modo de compartilhamento das tabelas atrav�s do M�dulo Configurador.[SIGACFG]"       
		lRet := .F.
		Exit
	EndIf
Next
		
Return lRet