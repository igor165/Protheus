#INCLUDE "UBAC011.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Static oArqTemp := Nil
Static oArqTemp2 := Nil

Function UBAC011()
	Local oColumn   := Nil
	Local aRet		:= {}
	Local aCoors	:= FWGetDialogSize( oMainWnd )
	Local cPerg		:= "UBAC011"
	Local aSeek		:= {}

	Private _nQtdl   	:= 0
	Private _cAliasTRB 	:= ""
    Private _cAliasTRB2	:= ""
	
	oBrowse	        := Nil
	oDlg            := Nil
	bKeyF12         := {|| If( Pergunte("UBAC011", .T.), ( _cAliasTRB := UBAC011TRB()[1], oBrowse:SetAlias(_cAliasTRB) ,oBrowse:Refresh()), .T. ) }
	SetKey( VK_F12, bKeyF12)
	
	If !Pergunte(cPerg, .T.)
		Return
	EndIf

	aRet := UBAC011TRB()  
	_cAliasTRB 	:= aRet[1] // Arquivo temporario
	aArqTemp 	:= aRet[2] // Estrutura do arquivo temporario

	Aadd(aSeek,{TxDadosCpo("DXI_FILIAL")[1],{{"",TamSX3("DXI_FILIAL")[3],TamSX3("DXI_FILIAL")[1],0,' ',,}}}) //Filial
	Aadd(aSeek,{TxDadosCpo("DXK_CODROM")[1],{{"",TamSX3("DXK_CODROM")[3],TamSX3("DXK_CODROM")[1],0,' ',,}}}) //Mala
	Aadd(aSeek,{TxDadosCpo("DXI_CODIGO")[1],{{"",TamSX3("DXI_CODIGO")[3],TamSX3("DXI_CODIGO")[1],0,' ',,}}}) //Fardo

	If Select(_cAliasTRB) > 0

		(_cAliasTRB)->(DbSetOrder(1))
		//- Coordenadas da area total da Dialog
		oSize := FWDefSize():New(.T.)
		oSize:AddObject('DLG',100,100,.T.,.T.)
		oSize:SetWindowSize(aCoors)
		oSize:lProp 	:= .T.
		oSize:Process()
		DEFINE MSDIALOG oDlg FROM oSize:aWindSize[1], oSize:aWindSize[2] TO oSize:aWindSize[3], oSize:aWindSize[4] OF oMainWnd PIXEL

		//-------------------------------------------------------------------
		// Define o Browse
		//-------------------------------------------------------------------
		DEFINE FWFORMBROWSE oBrowse DATA TABLE ALIAS _cAliasTRB DESCRIPTION STR0001 OF oDlg  //"Tempos de Produção até Emblocamento"
		// Filtro
		oBrowse:SetTemporary(.T.)
		oBrowse:SetFieldFilter(CmpFiltro(@aArqTemp))
		oBrowse:SetdbFFilter(.T.)
		oBrowse:SetUseFilter(.T.)
		oBrowse:SetProfileID('1')
		oBrowse:SetSeeK(,aSeek)
		oBrowse:DisableDetails()
		oBrowse:AddButton("Sair",{||oDlg:End()},,,,,,'10')
		ADD COLUMN oColumn DATA { || &(aArqTemp[1,1])  }			   	TITLE AGRTITULO("DXI_FILIAL")	SIZE  aArqTemp[1,3]  ;
		PICTURE PesqPict("DXI","DXI_FILIAL")  TYPE TamSX3("DXI_FILIAL")[3]	OF oBrowse //"FILIAL"
		ADD COLUMN oColumn DATA { || &(aArqTemp[2,1])  }			   	TITLE AGRTITULO("DXK_CODROM")	SIZE  aArqTemp[2,3]  ;
		PICTURE PesqPict("DXK","DXK_CODROM")  TYPE TamSX3("DXK_CODROM")[3]	OF oBrowse //"MALA"	
		ADD COLUMN oColumn DATA { || &(aArqTemp[3,1])  }			   	TITLE /*AGRTITULO("DXI_CODIGO")*/ STR0004	SIZE  aArqTemp[3,3]  ; 
		PICTURE PesqPict("DXI","DXI_CODIGO")  TYPE TamSX3("DXI_CODIGO")[3]	OF oBrowse //"FARDO"
		ADD COLUMN oColumn DATA { || &(aArqTemp[4,1])  }			   	TITLE /*AGRTITULO("NJJ_DATPS1")*/ STR0005	SIZE  aArqTemp[4,3]  ;
		PICTURE PesqPict("NJJ","NJJ_DATPS1")  TYPE TamSX3("NJJ_DATPS1")[3]	OF oBrowse //"Data Pesagem"
		ADD COLUMN oColumn DATA { || &(aArqTemp[5,1])  }			   	TITLE /*AGRTITULO("N72_DATENV")*/ STR0006	SIZE  aArqTemp[5,3]  ;
		PICTURE PesqPict("N72","N72_DATENV")  TYPE TamSX3("N72_DATENV")[3]	OF oBrowse //"Data envio"
		ADD COLUMN oColumn DATA { || &(aArqTemp[6,1])  }			   	TITLE /*AGRTITULO("DXJ_DTCLAS")*/ STR0007	SIZE  aArqTemp[6,3]  ;
		PICTURE PesqPict("DXJ","DXJ_DTCLAS")  TYPE TamSX3("DXJ_DTCLAS")[3]	OF oBrowse //"Data Clas."
		ADD COLUMN oColumn DATA { || &(aArqTemp[7,1])  }			   	TITLE /*AGRTITULO("DXJ_DATREC")*/ STR0008	SIZE  aArqTemp[7,3]  ;
		PICTURE PesqPict("DXJ","DXJ_DATREC")  TYPE TamSX3("DXJ_DATREC")[3]	OF oBrowse //"Data Receb."
		ADD COLUMN oColumn DATA { || &(aArqTemp[8,1])  }			   	TITLE /*AGRTITULO("DXJ_DATANA")*/ STR0009	SIZE  aArqTemp[8,3]  ;
		PICTURE PesqPict("DXJ","DXJ_DATANA")  TYPE TamSX3("DXJ_DATANA")[3]	OF oBrowse //"Data Ana."
		ADD COLUMN oColumn DATA { || &(aArqTemp[9,1])  }			   	TITLE /*AGRTITULO("DXD_DATAEM")*/ STR0010	SIZE  aArqTemp[9,3]  ;
		PICTURE PesqPict("DXD","DXD_DATAEM")  TYPE TamSX3("DXD_DATAEM")[3]	OF oBrowse //"Data Embl."
	
		//-------------------------------------------------------------------
		// Ativação do Browse
		//-------------------------------------------------------------------
		ACTIVATE FWFORMBROWSE oBrowse

		ACTIVATE MSDIALOG oDlg CENTER

		(_cAliasTRB)->(dbCloseArea())
	EndIf

	SetKey( VK_F12, Nil)
	
	//Elimina a tabela temporária, se houver
	AGRDLTPTB(oArqTemp)
	AGRDLTPTB(oArqTemp2)
	
Return

/*/{Protheus.doc} CmpFiltro
Função para retornar estrutuda dos campos do filtro
@author silvana.torres
@since 16/08/2018
@version undefined
@param aArqTemp, array, descricao
@type function
/*/
Static Function CmpFiltro(aArqTemp)
	Local aCampos := {}
	// Nom do cmp ,Desc. do campo           ,Tipo do campo   ,Tamanho         ,Decimal         ,Picture
	AAdd(aCampos,{aArqTemp[01][1], STR0011, aArqTemp[01][2], aArqTemp[01][3], aArqTemp[01][4], ""})
	AAdd(aCampos,{aArqTemp[02][1], STR0012, aArqTemp[02][2], aArqTemp[02][3], aArqTemp[02][4], ""})
	AAdd(aCampos,{aArqTemp[03][1], STR0004, aArqTemp[03][2], aArqTemp[03][3], aArqTemp[03][4], ""})
	AAdd(aCampos,{aArqTemp[04][1], STR0005,	aArqTemp[04][2], aArqTemp[04][3], aArqTemp[04][4], ""})
	AAdd(aCampos,{aArqTemp[05][1], STR0006,	aArqTemp[05][2], aArqTemp[05][3], aArqTemp[05][4], ""})
	AAdd(aCampos,{aArqTemp[06][1], STR0007,	aArqTemp[06][2], aArqTemp[06][3], aArqTemp[06][4], ""})
	AAdd(aCampos,{aArqTemp[07][1], STR0008,	aArqTemp[07][2], aArqTemp[07][3], aArqTemp[07][4], ""})
	AAdd(aCampos,{aArqTemp[08][1], STR0009, aArqTemp[08][2], aArqTemp[08][3], aArqTemp[08][4], ""})
	AAdd(aCampos,{aArqTemp[09][1], STR0010, aArqTemp[09][2], aArqTemp[09][3], aArqTemp[09][4], ""})

Return aCampos

/*/{Protheus.doc} UBAC011TRB
Cria arquivo de trabalho com dados para exibição da consulta
@author silvana.torres
@since 16/08/2018
@version undefined

@type function
/*/
Function UBAC011TRB()
	Local aArqTemp 		:= {}
	Local cArqTemp		:= ""
	Local cQuery		:= ""
	Local cFilQuery 	:= ""
	Local aCmpsTab 		:= {}
	Local nx	 		:= 0
	local aIndex 		:= {}
	
	Private _cAlias		:= GetNextAlias()
	
	If (!Empty(_cAliasTRB)) .AND. (Select(_cAliasTRB) > 0)
		(_cAliasTRB)->(dbCloseArea())
	EndIf

	dbSelectArea("SX3")

	// Cria arquivo de trabalho
	aCmpsTab := TamSX3("DXI_FILIAL")
	AADD(aArqTemp,{"DXI_FILIAL"   ,aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	
	aCmpsTab := TamSX3("DXK_CODROM" )
	AADD(aArqTemp,{"DXK_CODROM"	   ,aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	
	aCmpsTab := TamSX3("DXI_CODIGO" )
	AADD(aArqTemp,{"DXI_CODIGO"	   ,aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})

	aCmpsTab := TamSX3("NJJ_DATPS1")
	AADD(aArqTemp,{"NJJ_DATPS1"   ,aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	
	aCmpsTab := TamSX3("N72_DATENV" )
	AADD(aArqTemp,{"N72_DATENV"	   ,aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	
	aCmpsTab := TamSX3("DXJ_DTCLAS" )
	AADD(aArqTemp,{"DXJ_DTCLAS"	   ,aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	
	aCmpsTab := TamSX3("DXJ_DATREC")
	AADD(aArqTemp,{"DXJ_DATREC"   ,aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	
	aCmpsTab := TamSX3("DXJ_DATANA" )
	AADD(aArqTemp,{"DXJ_DATANA"	   ,aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	
	aCmpsTab := TamSX3("DXD_DATAEM" )
	AADD(aArqTemp,{"DXD_DATAEM"	   ,aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	   
	//-- Cria Indice de Trabalho

	cArqTemp := GetNextAlias()
	For nx := 1 To Len(aArqTemp)
		if aArqTemp[nx,1] $ "FILIAL|MALA|FARDO"
			//A funcao AgrCrTpTb adiciona o nome do indice
			AADD(aIndex,{"i"+cValToChar(nx), aArqTemp[nx,1]})
		Endif
	Next nX 	
	oArqTemp := AGRCRTPTB(cArqTemp, {aArqTemp, aIndex })
	_cAliasTRB := cArqTemp
	
	#IFDEF TOP
	cQuery	:= " 	SELECT DXI.DXI_FILIAL, DXK.DXK_CODROM, DXI.DXI_CODIGO, NJJ.NJJ_DATPS1, N72.N72_DATENV, "
	cQuery	+= " 	       DXJ.DXJ_DTCLAS, DXJ.DXJ_DATREC, DXJ.DXJ_DATANA, DXD.DXD_DATAEM "
	cQuery	+= "	  FROM "+RetSqlName("DXI")+" DXI "
	cQuery	+= "	 	   INNER JOIN "+RetSqlName("DXD")+" DXD "
	cQuery	+= "		   ON DXD.D_E_L_E_T_   = ' ' "
   	cQuery	+= "  		   AND DXD.DXD_FILIAL = DXI.DXI_FILIAL "	
   	cQuery	+= "		   AND DXD.DXD_SAFRA  = DXI.DXI_SAFRA "	
   	cQuery	+= "		   AND DXD.DXD_CODIGO = DXI.DXI_BLOCO "
   	cQuery	+= "		   INNER JOIN "+RetSqlName("DXK")+" DXK " 
   	cQuery	+= "		   ON DXK.D_E_L_E_T_   = ' '  "
   	cQuery	+= "		   AND DXK.DXK_FILIAL = DXI.DXI_FILIAL "	
   	cQuery	+= "		   AND DXK.DXK_SAFRA  = DXI.DXI_SAFRA	 "
   	cQuery	+= "		   AND DXK.DXK_FARDO  = DXI.DXI_CODIGO	 "
   	cQuery	+= "		   AND DXK.D_E_L_E_T_  = DXI.D_E_L_E_T_	 "
   	//cQuery	+= "		   AND DXK.DXK_TIPO 	= '1' "
   	cQuery	+= "		   INNER JOIN "+RetSqlName("DXJ")+" DXJ "
   	cQuery	+= "		   ON DXJ.D_E_L_E_T_   = ' ' " 
   	cQuery	+= "		   AND DXJ.DXJ_FILIAL = DXK.DXK_FILIAL "	
   	cQuery	+= "		   AND DXJ.DXJ_SAFRA  = DXK.DXK_SAFRA	 "
   	cQuery	+= "		   AND DXJ.DXJ_CODIGO = DXK.DXK_CODROM "
   	cQuery	+= "		   AND DXJ.DXJ_TIPO	  = DXK.DXK_TIPO "
   	//cQuery	+= "		   AND DXJ.DXJ_TIPO 	= '1' "
   	cQuery	+= "		   INNER JOIN "+RetSqlName("N73")+" N73 "
   	cQuery	+= "		   ON N73.D_E_L_E_T_   = ' ' " 
   	cQuery	+= "		   AND N73.N73_FILIAL = DXJ.DXJ_FILIAL "	
   	cQuery	+= "		   AND N73.N73_CODMAL = DXJ.DXJ_CODIGO "
   	cQuery	+= "		   AND N73.N73_CODSAF = DXJ.DXJ_SAFRA "
   	//cQuery	+= "		   AND N73.N73_TIPO   = '1' "
   	cQuery	+= "		   INNER JOIN "+RetSqlName("N72")+" N72 "
   	cQuery	+= "		   ON N72.D_E_L_E_T_   = ' ' " 
   	cQuery	+= "		   AND N72.N72_FILIAL = N73.N73_FILIAL "	
   	cQuery	+= "		   AND N72.N72_SAFRA  = N73.N73_CODSAF "
   	cQuery	+= "		   AND N72.N72_CODREM = N73.N73_CODREM "
   	cQuery	+= "		   AND N72.N72_TIPO	  = N73.N73_TIPO "
   	cQuery	+= "		   INNER JOIN "+RetSqlName("DX0")+" DX0 "
   	cQuery	+= "		   ON DX0.D_E_L_E_T_   = ' ' " 
   	cQuery	+= "		   AND DX0.DX0_FILIAL = DXI.DXI_FILIAL "	
   	cQuery	+= "		   AND DX0.DX0_FARDAO = DXI.DXI_FARDAO "
   	cQuery	+= "		   AND DX0.DX0_TIPROM = '1' "
   	cQuery	+= "		   INNER JOIN "+RetSqlName("NJJ")+" NJJ "
   	cQuery	+= "		   ON NJJ.D_E_L_E_T_   = ' ' " 
   	cQuery	+= "		   AND NJJ.NJJ_FILIAL = DX0.DX0_FILIAL "	
   	cQuery	+= "		   AND NJJ.NJJ_CODROM = DX0.DX0_NRROM "

	cFilQuery := " WHERE DXI.D_E_L_E_T_   = ' '  "	

	If !Empty(mv_par01) //Safra
		cFilQuery += "	AND DXI.DXI_SAFRA = '" + mv_par01 +"'"
	EndIf
	
	cQuery += cFilQuery
	
	cQuery := ChangeQuery(cQuery)

	dbUseArea( .T., 'TOPCONN', TcGenQry( , , cQuery), _cAlias, .F., .T. )

	Count To _nQtdl
	Processa({|| UBAC011P() },STR0002) //Aguarde...

Return({cArqTemp, aArqTemp})


Static Function UBAC011P()
	If (!Empty(_cAliasTRB)) .AND. (Select(_cAliasTRB) > 0)
		(_cAliasTRB)->(dbGoTop())
	EndIf
	ProcRegua(_nQtdl)
	nRegl := 0
	(_cAlias)->(dbGotop())
	While (_cAlias)->(!Eof())
		nRegl ++
		IncProc(STR0003+Alltrim(Str(nRegl,5))+" / "+Alltrim(Str(_nQtdl,5))) //"Processando Registro -> "
		// Atualiza arquivo temporário com o resultado da Query
		Reclock(_cAliasTRB,.T.)
		Replace DXI_FILIAL   	With (_cAlias)->(DXI_FILIAL)
		Replace DXK_CODROM		With (_cAlias)->(DXK_CODROM)
		Replace DXI_CODIGO		With (_cAlias)->(DXI_CODIGO)
		Replace NJJ_DATPS1   	With StoD((_cAlias)->(NJJ_DATPS1))
		Replace N72_DATENV		With StoD((_cAlias)->(N72_DATENV))
		Replace DXJ_DTCLAS		With StoD((_cAlias)->(DXJ_DTCLAS))
		Replace DXJ_DATREC   	With StoD((_cAlias)->(DXJ_DATREC))
		Replace DXJ_DATANA		With StoD((_cAlias)->(DXJ_DATANA))
		Replace DXD_DATAEM		With StoD((_cAlias)->(DXD_DATAEM))

		Msunlock()
		(_cAlias)->( dbSkip() )
	Enddo
	dbGoTop()
	#ENDIF
	(_cAlias)->(dbCloseArea())
Return