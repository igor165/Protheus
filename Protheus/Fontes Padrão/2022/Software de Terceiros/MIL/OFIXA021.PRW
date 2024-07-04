#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"  
#include "OFIXA021.CH"
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | OFIXA021   | Autor | Luis Delorme          | Data | 19/11/14 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Faturamento agrupado de orçamentos de Peças                  |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFIXA021()

Local cQuery
Local nCntFor := .f.        
Local cAliasVS3 := "SQLVS3"
Local cAliasVEC := "SQLVEC"
Local aRet       := {}
Local aParamBox  := {}
Local cStatus    := STR0028 // Todos
Local aStatus    := {STR0028,STR0029,STR0030} // Todos / Liberado para Faturamento / Aguardando outro Orçamento

Private _cNomArq := "OFIXA021"
Private cCliente := ""
Private cCadastro := STR0004 // Faturamento agrupado de orçamentos de Peças
Private aSay := {}
Private aButton := {}
Private aTotais    := {}
Private cQryAl001

Private aOrcFat := {}
Private nImprRoman := 0

//Verifica se existe o paramentro 2 da pergunta OF011F12
If ( SX1->( DbSeek( PadR("OF011F12" , Len(SX1->X1_GRUPO) ) + "02" ) ) )
	Pergunte("OF011F12",.f.)
	nImprRoman := MV_PAR02
EndIf

INCLUI := .T. 

aAdd(aParamBox,{1,STR0009,space(GetSx3Cache("A1_COD","X3_TAMANHO")),"@!",'vazio().or.FG_Seek("SA1","MV_PAR01",1,.f.)',"SA1",".t.",060,.t.}) // Cliente
aAdd(aParamBox,{1,STR0010,space(GetSx3Cache("A1_LOJA","X3_TAMANHO")),"@!",'vazio().or.FG_Seek("SA1","MV_PAR01+MV_PAR02",1,.f.)',"",".t.",030,.t.}) // Loja
aAdd(aParamBox,{1,STR0011,dDataBase-day(dDataBase),"@D",'',"","",060,.f.}) // De
aAdd(aParamBox,{1,STR0012,dDataBase,"@D",'',"","",060,.f.}) // Até
aAdd(aParamBox,{1,STR0024,space(GetSx3Cache("VS1_CODVEN","X3_TAMANHO")),"@!",'vazio().or.FG_Seek("SA3","MV_PAR05",1,.f.)',"SA3","",60,.f.}) // Vendedor
aAdd(aParamBox,{2,STR0027,cStatus,aStatus,100,"",.t.,".t."}) // Status
If !ParamBox(aParamBox,"",@aRet,,,,,,,,.T.,.T.)
	Return
Endif

cQryAl001 := GetNextAlias()

cQuery := "SELECT VS1.VS1_NUMORC , VS1.VS1_STATUS , VS1.VS1_DATORC , VS1.VS1_VTOTNF"
cQuery += "  FROM "+RetSQLName("VS1")+" VS1 "
cQuery += " WHERE VS1.VS1_FILIAL = '"+xFilial("VS1")+"'"
cQuery +=   " AND VS1.VS1_TIPORC = '1' "
If aRet[6] == STR0029 // Liberado para Faturamento
	cQuery += " AND VS1.VS1_STATUS = 'F' "
ElseIf aRet[6] == STR0030 // Aguardando outro Orçamento
	cQuery += " AND VS1.VS1_STATUS = 'G' "
Else // Todos
	cQuery += " AND VS1.VS1_STATUS IN ('F','G') "
EndIf
cQuery +=   " AND VS1.VS1_CLIFAT = '" + aRet[1] + "'"
cQuery +=   " AND VS1.VS1_LOJA = '" + aRet[2] + "'"
If !Empty(aRet[3])
	cQuery +=   " AND VS1.VS1_DATORC >= '" + Dtos(aRet[3]) + "'"
EndIf
If !Empty(aRet[4])
	cQuery +=   " AND VS1.VS1_DATORC <= '" + Dtos(aRet[4]) + "'"
Endif
If !Empty(aRet[5])
	cQuery +=   " AND VS1.VS1_CODVEN = '" + aRet[5] + "'"
Endif
cQuery +=   " AND VS1.D_E_L_E_T_ = ' '"

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAl001, .F., .T. )
//
aIntCab := {}
aIntIte := {}
aAdd(aIntCab, {STR0005,"C", 60, "@!"               }) // Número
aAdd(aIntCab, {STR0027,"C",120, "@!"               }) // Status
aAdd(aIntCab, {STR0007,"D", 50, "@D"               }) // Data Abertura
aAdd(aIntCab, {STR0008,"N", 55, "@E 999,999,999.99"}) // Valor Total

aAdd(aTotais,{STR0014,0,0}) // TOTAL GERAL
aAdd(aTotais,{STR0015,0,0}) // TOTAL SELECIONADO
                 
nPosVet := 1
while !((cQryAl001)->(eof()))

	aAdd(aIntIte,{;
	(cQryAl001)->(VS1_NUMORC),;
	IIf((cQryAl001)->(VS1_STATUS)=="F",STR0029,STR0030),; // Liberado para Faturamento / Aguardando outro Orçamento
	stod((cQryAl001)->(VS1_DATORC)),;
	(cQryAl001)->(VS1_VTOTNF) })                 

	// Ponto de entrada para inclusão de campo no listbox da tela  
	If ExistBlock("OX021TEL")
		ExecBlock("OX021TEL",.f.,.f.,{nPosVet,.f.})
	EndIf
	
	aTotais[1,2] ++
	aTotais[1,3] += (cQryAl001)->(VS1_VTOTNF)
	nPosVet++

	(cQryAl001)->(dbSkip())
enddo    

(cQryAl001)->(DBCloseArea())  


cNome := FM_SQL(" SELECT A1_NOME FROM " +RetSqlName('SA1')+ " WHERE A1_FILIAL = '"+xFilial("SA1")+"' AND A1_COD = '"+aRet[1]+"' AND A1_LOJA = '"+aRet[2]+"' AND D_E_L_E_T_ = ' ' ")
if OX021AGRU(aRet[1] , cCadastro , aIntCab , aIntIte , .f. , aRet[2] , cNome ) == 1
	
	aOrcs := {}
	
	for nCntFor := 1 to Len(aIntIte)
		if aIntIte[nCntFor,1]
			aAdd(aOrcs,aIntIte[nCntFor,2])
		endif
	next
	if LEN(aOrcs) <= 0
		MsgInfo(STR0026) //"Nenhum orçamentos selecionado para agrupar"
		OFIXA021()
		return
	endif
	nVerParFat := 2
	if OFIXX004("VS1",3,aOrcs)
		lAchou := .f.
		for nCntFor := 1 to Len(aOrcs)
			dbSelectArea("VS1")
			dbSetOrder(1)
			dbSeek(xFilial("VS1")+aOrcs[nCntFor])
			If VS1->VS1_STATUS == "X" // Orcamento Faturado    
				// Gravacao do VEC_NUMORC       

				if !lAchou
					cQuery := "SELECT VEC.R_E_C_N_O_ VECRECNO "
					cQuery += "FROM "
					cQuery += RetSqlName( "VEC" ) + " VEC "
					cQuery += "WHERE "
					cQuery += "VEC.VEC_FILIAL='"+ xFilial("VEC")+ "' AND VEC.VEC_NUMNFI = '"+VS1->VS1_NUMNFI+"' AND VEC.VEC_SERNFI = '"+VS1->VS1_SERNFI+"' AND "
					cQuery += "VEC.D_E_L_E_T_=' '"
					
					dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVEC, .T., .T. )
					
					Do While !( cAliasVEC )->( Eof() )
						
						dbSelectArea("VEC")
						DBGoto(( cAliasVEC )->(VECRECNO))
						RecLock("VEC",.f.)
						VEC->VEC_NUMORC := ""
						MsUnLock()
						lAchou := .t.
						dbSelectArea(cAliasVEC)
						( cAliasVEC )->(dbSkip())
					Enddo
					(cAliasVEC)->(DBCloseArea())
				Endif
				
				cQuery := "SELECT VS3.VS3_GRUITE , VS3.VS3_CODITE , VS3.VS3_QTDITE , VS3.VS3_VALTOT "
				cQuery += "FROM "
				cQuery += RetSqlName( "VS3" ) + " VS3 "
				cQuery += "WHERE "
				cQuery += "VS3.VS3_FILIAL='"+ xFilial("VS3")+ "' AND VS3.VS3_NUMORC = '"+VS1->VS1_NUMORC+"' AND "
				cQuery += "VS3.D_E_L_E_T_=' '"
				
				dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVS3, .T., .T. )
				
				Do While !( cAliasVS3 )->( Eof() )
					
					cQuery := "SELECT VEC.R_E_C_N_O_ VECRECNO "
					cQuery += "FROM "
					cQuery += RetSqlName( "VEC" ) + " VEC "
					cQuery += "WHERE "
					cQuery += "VEC.VEC_FILIAL='"+ xFilial("VEC")+ "' AND VEC.VEC_NUMNFI = '"+VS1->VS1_NUMNFI+"' AND VEC.VEC_SERNFI = '"+VS1->VS1_SERNFI+"' AND "
					cQuery += "VEC.VEC_GRUITE = '"+( cAliasVS3 )->VS3_GRUITE+"' AND VEC.VEC_CODITE = '"+( cAliasVS3 )->VS3_CODITE+"' AND VEC.VEC_QTDITE = "+Alltrim(str(( cAliasVS3 )->VS3_QTDITE))+" AND "
					cQuery += "VEC.VEC_VALVDA = "+Alltrim(str(( cAliasVS3 )->VS3_VALTOT))+" AND VEC.VEC_NUMORC = ' ' AND "
					cQuery += "VEC.D_E_L_E_T_=' '"
					nRecno := FM_SQL(cQuery)
					
					If nRecno > 0
						dbSelectArea("VEC")
						DBGoto(nRecno)     
						RecLock("VEC",.f.)
						VEC->VEC_NUMORC := VS1->VS1_NUMORC
						MsUnLock()
					Endif
					
					dbSelectArea(cAliasVS3)
					( cAliasVS3 )->(dbSkip())
					
				Enddo
				(cAliasVS3)->(DBCloseArea())
				dbSelectArea("VS1")
									
				OX001CEV("F",VS1->VS1_NUMORC,VS1->VS1_TIPORC) // Gerar CEV na Finalizacao do Orcamento ( Pos-Venda )
			endif
		
			UnlockByName( 'OFIXX001_' + aOrcs[nCntFor] , .T., .F. ) // Destravar os ORCAMENTOS
		
		next

		If nImprRoman == 2 .and. ExistBlock("ROMBALCAO")
			ExecBlock("ROMBALCAO",.f.,.f.,{VS1->VS1_SERNFI,VS1->VS1_NUMNFI})
		EndIf
		
		OFIXA021() // Chamar novamente a tela de parametro ao confirmar a rotina

	Else

		for nCntFor := 1 to Len(aOrcs)
			UnlockByName( 'OFIXX001_' + aOrcs[nCntFor] , .T., .F. ) // Destravar os ORCAMENTOS
		Next
		
	endif
Else
	if len(aIntIte) == 0 
		MsgInfo(STR0025) // Não há dados para esta pesquisa
	Else
		for nCntFor := 1 to Len(aIntIte)
			if aIntIte[nCntFor,1]
				UnlockByName( 'OFIXX001_' + aIntIte[nCntFor,2] , .T., .F. ) // Destravar os ORCAMENTOS
			endif
		next
	Endif
	OFIXA021() // Chamar novamente a tela de parametro ao cancelar a rotina
Endif
return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | OX021AGRU  | Autor | Thiago                | Data | 25/01/16 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Seleciona orcamentos para faturamento.		                   |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function OX021AGRU( _cCliente , _cTitulo , _aIntCab , _aIntIte , _lAbrXML , _cLoja , _cNome )
Local ni         := 0
Local nj         := 0
Local nTam       := 0
Local lMarca     := .f.
Local oFont1     := TFont():New(,11,24,,.F.,,,,,,,,,,,)
Local aObjects   := {} , aInfo := {}, aPos := {}
Local aSizeHalf  := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local _aCabImp   := {}
Private oOkTik   := LoadBitmap( GetResources() , "LBTIK" )
Private oNoTik   := LoadBitmap( GetResources() , "LBNO" )
Private nOrd     := 0
Private cCreDec  := "<"
Default _cNomArq := "OX021AGRU"
Default _cTitulo := ""
Default _aIntCab := {}
Default _aIntIte := {}
Default _lAbrXML := .f.   

nRet := 0

If len(_aIntCab) > 0 .and. len(_aIntIte) > 0
	aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
	aAdd( aObjects, { 0 , 43 , .T. , .F. } ) // Cliente / Totais / Botoes
	aAdd( aObjects, { 0 ,  0 , .T. , .T. } ) // ListBox
	aPos := MsObjSize( aInfo, aObjects )
	For ni := 1 to len(_aIntIte) // Adicionar campo de TIK no vetor (1a.coluna)
		_aIntIte[ni] := aSize(_aIntIte[ni],Len(_aIntIte[ni])+1) // Criar uma posicao a mais no vetor
		_aIntIte[ni] := aIns(_aIntIte[ni],1) // inserir 1a. coluna
		_aIntIte[ni,1] := .f.
	Next
	_aCabImp := aClone(_aIntCab)
	For ni := 1 to len(_aCabImp)
		If _aCabImp[ni,2] == "C" // alinhar colunas CARACTER
			nTam := 1
			For nj := 1 to len(_aIntIte)
				If nTam < len(_aIntIte[nj,ni+1])
					nTam := len(_aIntIte[nj,ni+1])
				EndIf
			Next
			_aCabImp[ni,1] := left(_aCabImp[ni,1]+space(nTam),nTam)
			For nj := 1 to len(_aIntIte)
				_aIntIte[nj,ni+1] := left(_aIntIte[nj,ni+1]+space(nTam),nTam)
			Next
		ElseIf _aCabImp[ni,2] == "D" // alinhar colunas DATA
			nTam := len(Transform(dDatabase,_aCabImp[ni,4]))
			_aCabImp[ni,1] := left(_aCabImp[ni,1]+space(nTam),nTam)
		ElseIf _aCabImp[ni,2] == "N" // alinhar colunas NUMERICO
			nTam := len(Transform(1,_aCabImp[ni,4]))
			_aCabImp[ni,1] := right(space(nTam)+_aCabImp[ni,1],nTam)
		EndIf
	Next
	DEFINE MSDIALOG oDlgVisual FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE (cCadastro) OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS
	oDlgVisual:lEscClose := .F.
	oLbVisual := TWBrowse():New(aPos[2,1]+2,aPos[2,2]+2,(aPos[2,4]-aPos[2,2]-4),(aPos[2,3]-aPos[2,1]-4),,,,oDlgVisual,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oLbVisual:nAT := 1
	oLbVisual:SetArray(_aIntIte)
	oLbVisual:addColumn( TCColumn():New( "" , { || IIf(_aIntIte[oLbVisual:nAt,1] , oOkTik , oNoTik ) } ,,,,"LEFT" ,05,.T.,.F.,,,,.F.,) ) // Tik
	For ni := 1 to len(_aIntCab)
		If _aIntCab[ni,2] == "L"
			oLbVisual:addColumn( TCColumn():New( _aIntCab[ni,1] , &("{ || _aIntIte[oLbVisual:nAt,"+Alltrim(str(ni+1))+"] }")	,,,, "LEFT" , _aIntCab[ni,3],.F.,.F.,,,,.F.,) )	// Colunas LOGICAS
		Else
			oLbVisual:addColumn( TCColumn():New( _aIntCab[ni,1] , &("{ || Transform(_aIntIte[oLbVisual:nAt,"+Alltrim(str(ni+1))+"],_aIntCab["+Alltrim(str(ni))+",4]) }")	,,,, IIf(_aIntCab[ni,2]<>"N","LEFT","RIGHT") , _aIntCab[ni,3],.F.,.F.,,,,.F.,) ) // DEMAIS Colunas
		EndIf
	Next
	oLbVisual:bLDblClick := { || FS_DBCLICK(_aIntIte,oLbVisual:nAt) }
	oLbVisual:bHeaderClick := { |oObj,nCol| IIf( nCol==1, ( lMarca := !lMarca , FS_MARCA(_aIntIte,lMarca) ) , FGX_IMPVI("O",,,,_aIntIte,nCol,) ) , oLbVisual:Refresh() }
	oLbVisual:Refresh()   
	
	@ aPos[1,1]+010,aPos[1,1] SAY oNomTitulo VAR STR0016+" "+(_cCliente)+" - "+(_cLoja) SIZE 450,13 FONT oFont1 OF oDlgVisual PIXEL // Cód.Cliente: 
	@ aPos[1,1]+025,aPos[1,1] SAY oNomTitulo VAR STR0017+" "+(_cNome) SIZE 450,13 FONT oFont1 OF oDlgVisual PIXEL                 // Nome: 
	
	@ aPos[1,1]+012,aPos[1,4]-250 BUTTON oImprimir PROMPT STR0018 OF oDlgVisual SIZE 80,11 PIXEL ACTION FS_IMPR(_cNomArq,_cTitulo,_aCabImp,_aIntIte)             // Imprimir
	@ aPos[1,1]+026,aPos[1,4]-250 BUTTON oExpExcel PROMPT STR0019 OF oDlgVisual SIZE 80,11 PIXEL ACTION FS_GERAXML(_cNomArq,_cTitulo,_aIntCab,_aIntIte,_lAbrXML) // Exportar XML

	@ aPos[1,1] + 003 , aPos[1,2] TO aPos[1,3] , aPos[1,4]-163 LABEL OF oDlgVisual PIXEL 

	oLblValor := TWBrowse():New(aPos[1,1],aPos[1,4]-162,160,47,,,,oDlgVisual,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oLblValor:nAT := 1
	oLblValor:SetArray(aTotais)
	oLblValor:addColumn( TCColumn():New( STR0020 , { || aTotais[oLblValor:nAt,1] }	,,,, "LEFT" , 65 ,.F.,.F.,,,,.F.,) )
	oLblValor:addColumn( TCColumn():New( STR0021 , { || Transform(aTotais[oLblValor:nAt,2],"@E 999999") }	,,,, "RIGHT" , 35 ,.F.,.F.,,,,.F.,) )
	oLblValor:addColumn( TCColumn():New( STR0022 , { || Transform(aTotais[oLblValor:nAt,3],"@E 999,999,999.99") }	,,,, "RIGHT" , 45 ,.F.,.F.,,,,.F.,) )

	ACTIVATE MSDIALOG oDlgVisual ON INIT EnchoiceBar(oDlgVisual,{|| nRet := 1, oDlgVisual:End() },{|| nRet := 2, oDlgVisual:End() },,)
EndIf
Return(nRet)

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | FS_DBCLICK | Autor | Thiago                | Data | 25/01/16 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Seleciona orcamentos.							                   |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function FS_DBCLICK(_aIntIte,nLin)
Local nPos    := 0
Local oArrHlp := DMS_ArrayHelper():New()

If !_aIntIte[nLin,1] // Vai Marcar - verifica se o orçamento ta bloqueado e bloqueia o mesmo
	If OX0010115_BloqueiaOrcamento( _aIntIte[nLin,2] )
		Return
	EndIf
Else // Vai desmarcar - desbloqueia o orçamento
	UnlockByName( 'OFIXX001_' + _aIntIte[nLin,2], .T., .F. )
EndIf

If ExistBlock("OX021TEL")
	ExecBlock("OX021TEL",.f.,.f.,{nLin,.t.}) // Passado .t. no 2o Parâmetro quando se tratar de Duplo Clique
EndIf

_aIntIte[nLin,1] := !_aIntIte[nLin,1]

// Verificando se o array tem duas ou mais marcações
nPos := Len(oArrHlp:Select(_aIntIte, {|x| x[1]}))
If nPos >= 2 .And. ExistBlock("OX021MARC")
	// Ponto de Entrada para verificar se a marcação é válida ou não conforme validação customizada
	_aIntIte := ExecBlock("OX021MARC", .f., .f., {_aIntIte})
EndIf

aTotais[2,2] := 0
aTotais[2,3] := 0
For nPos := 1 to len(_aIntIte)
	if _aIntIte[nPos,1]
		aTotais[2,2] ++
		aTotais[2,3] += _aIntIte[nPos,5]
	Endif
Next

oLblValor:SetArray(aTotais)
oLblValor:refresh()

Return(.t.)

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | FS_IMPR    | Autor | Thiago                | Data | 25/01/16 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Impressão.											                   |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function FS_IMPR(_cNomArq,_cTitulo,_aCabImp,_aIntIte)  
Local aImpTot := {} 
                                         
aImpTot := aClone( _aIntIte )
aAdd(aImpTot,{.t.,STR0023,aTotais[2,2],space(len(dtoc(aImpTot[1,4]))),aTotais[2,3]}) // TOTAL   

FGX_IMPVI("I",_cNomArq,_cTitulo,_aCabImp,aImpTot,,)

Return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | FS_GERAXML | Autor | Thiago                | Data | 25/01/16 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Gera planilha excel. 							                   |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function FS_GERAXML(_cNomArq,_cTitulo,_aIntCab,_aIntIte,_lAbrXML)                           

aImpTot := aClone( _aIntIte )
aAdd(aImpTot,{.t.,STR0023,aTotais[2,2],"        ",aTotais[2,3]}) // TOTAL   

FGX_IMPVI("E",_cNomArq,_cTitulo,_aIntCab,aImpTot,,_lAbrXML)

Return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | FS_GERAXML | Autor | Thiago                | Data | 25/01/16 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Seleciana orçamentos. 							                   |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function FS_MARCA(_aIntIte,lMarca)
Local _i   := 0
Local nPos := 0

aTotais[2,2] := 0
aTotais[2,3] := 0

For _i := 1 to Len(_aIntIte)

	if !_aIntIte[_i,1] .and. lMarca // Se nao estiver marcado e é para marcar

		If OX0010115_BloqueiaOrcamento( _aIntIte[_i,2] ) // verifica se ta bloqueado e tenta bloquear
			_aIntIte[_i,1] := .f.
			Loop
		EndIf
		_aIntIte[_i,1] := .t.

	ElseIf _aIntIte[_i,1] .and. !lMarca // Se estiver marcado e é para desmarcar
		UnlockByName( 'OFIXX001_' + _aIntIte[_i,2], .T., .F. )
		_aIntIte[_i,1] := .f.
	Endif

	If _aIntIte[_i,1]
		aTotais[2,2] ++
		aTotais[2,3] += _aIntIte[_i,5]
	EndIf

Next

// Verificando se o array tem marcação
nPos := aScan(_aIntIte, {|x| x[1]})
If nPos > 0 .And. ExistBlock("OX021MARC")
	// Ponto de Entrada para verificar se a marcação é válida ou não conforme validação customizada
	_aIntIte := ExecBlock("OX021MARC", .f., .f., {_aIntIte})
EndIf

oLblValor:SetArray(aTotais)
oLblValor:refresh()

Return()