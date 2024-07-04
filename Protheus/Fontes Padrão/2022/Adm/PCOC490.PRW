// Copyright (C) 2008, Microsiga
#include 'MSGRAPHI.CH'

#include "protheus.ch"
#include "dbtree.ch"
#include "tbiconn.ch"
#include "msmgadd.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOC490   ºAutor  ³Acacio Egas         º Data ³  20/03/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Consulta Fluxo de Caixa para o planejamento.               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAPCO                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static lDrilDrow
Static nTpGraf

Function PCOC490(cSeek,cFiltro,cTitulo,nNivel,lSide)

Local nWidth  	:= GetScreenRes()[1] - 40
Local nHeight 	:= GetScreenRes()[2] - 200
 Local aCabec
Local aButtons
//Private _aListData := PcoRetPer(ALV->ALV_INIPER,ALV->ALV_FIMPER,ALV->ALV_TPPERI,.F.)
Default lSide 	:= .T.
Default cTitulo := "Consulta Fluxo de caixa planejado"
Default nNivel 	:= 0
lDrilDrow := !lSide
//DbSelectArea("ALV")

Private oFluxo 	:= PCOArea():New(nNivel*40,0, nWidth, nHeight,cTitulo)
Private aSeries	:= {nil,nil,nil}
Private aConfigs := {}
Private aCampos := {{'','',0,0,0}}
// Monta Estrutura do Tree
nNivel ++
oFluxo:AddLayout("Fluxo")

/*
If nNivel>1

	oPanel := TPanel():New(0,0,'',oFluxo:oDlg, , .T., .T.,, ,10,20,.T.,.T. )
	oPanel:Align := CONTROL_ALIGN_TOP
	
	@ 2,4 SAY "Drilldown" of oPanel SIZE 120,9 PIXEL FONT oBold COLOR RGB(80,80,80)
	@ 3,3 BITMAP oBar RESNAME "MYBAR" Of oPanel SIZE BrwSize(oFluxo:oDlg,0)/2,8 NOBORDER When .F. PIXEL ADJUST
	@ 12,2   SAY "Chave" Of oPanel PIXEL SIZE 640 ,79 FONT oBold
	
EndIf
*/
If lSide

	oFluxo:addSide(33,"Cubos")
	
	oFluxo:AddWindow(70,"WIN1","Cubos",2,.F.,.F.,oFluxo:oArea:oSideBar)
	
	oFluxo:AddTre("001","WIN1",nil)
	MontaCub(@oFluxo:GetTre("001"))
	
	// Adiciona Janela 2
	oFluxo:AddWindow(26,"WIN2","Configuração",1,.F.,.F.,oFluxo:oArea:oSideBar)
	
	aTipos := {"01-Linear" ,"02-Area" ,"03-Pontos" ,"04-Bar" ,"05-Piramide" ,"06-Cilindro" ,"07-HBAR" ,"08-HPYRAMID" ,"09-HCILINDER" ,"10-PIE" ,"11-SHAPES" ,"12-FASTLINE" ,"13-ARROWS" ,"14-GANTT" ,"15-BUBBLE" }
	
	aConfigs := {nil,nil,nil}
	aParametros := {{ 2 ,"Tp. Graf.", 1 ,aTipos,50, ,.T. }}
	
	ParamBox(aParametros 	,"Parametros"	, @aConfigs,,,.F.	,120,3	, oFluxo:oArea:GetPanel( "WIN2" ),"PCOC490_1" )

EndIf

// Adiciona Janela 3
oFluxo:AddWindow(48,"WIN3","Fluxo de Caixa do Planejamento",4)

aButtons := {	{1 , "PMSZOOMIN"	, {|| } , "Drilldown"		},;
				{1 , "BMPPOST"		, {|| } , "Enviar Emial"	},;
				{1 , "PMSEXCEL"		, {|| DlgToExcel({{"ARRAY","Excel" ,aHeader,aView}}) }, "Exportar p/ Excel"}}

oFluxo:BarBut(aButtons,"WIN3","Fluxo")

If !Empty(cSeek)
	aCabec := {}
	DbSelectArea("AKW")
	DbSetOrder(1)
	DbSeek(cSeek)
	cCampo := 	SubStr(AKW->AKW_CHAVER,6)
	cCampo := StrTran(cCampo,"AKD","ALX")
	If !("TPSALD" $ AKW->AKW_CHAVER)
		aAdd(aCabec,AKW->AKW_DESCRI)
		aAdd(aCabec,"Descrição")
	Else
		aAdd(aCabec,"Data")
	Endif
	aAdd(aCabec,"Entrada")
	aAdd(aCabec,"Saida")	
	aAdd(aCabec,"Saldo")		
Else
	aCabec := {"Entidade","Descrição","Entrada","Saida","Saldo"}		
EndIf
oFluxo:AddBrw("001",nil,aCabec,"WIN3","Fluxo",{|| })

oFluxo:GetBrw("001"):blDblClick := { || If(!Empty(aCampos[oFluxo:GetBrw("001"):nat,6]),PCOC490(aCampos[oFluxo:GetBrw("001"):nat,6],aCampos[oFluxo:GetBrw("001"):nat,7],aCampos[oFluxo:GetBrw("001"):nat,8],nNivel,.f.),) }
oFluxo:GetBrw("001"):SetArray(aCampos)
oFluxo:GetBrw("001"):bLine := {|| aCampos[oFluxo:GetBrw("001"):nAt] }
oFluxo:GetBrw("001"):Refresh()

oFluxo:AddWindow(48,"WIN4","Grafico Demostrativo",3)

aButtons := {	{1 , "PMSSUPALOC"	, {|| } , "Exibir/Esconder Grafico"		},;
				{1 , "GPRIMG32"		, {|| } , "Imprimir/Gerar Grafico em formato BMP"	}}

oFluxo:BarBut(aButtons,"WIN4","Fluxo")


oGraphic :=  TMSGraphic():New(0,0,oFluxo:oArea:GetPanel( "WIN4" ), , /*[anClrText]*/,/* [anClrBack]*/,400,200)
If !Empty(cSeek) .and. !Empty(cFiltro)
	RunPlanej("AKW"+cSeek,cFiltro)
Endif
// Itens do Grafico

oFluxo:ShowLayout("Fluxo")

oFluxo:Activate(.T.)

Return

Static Function MontaCub(oTree)
Local nX := 1
Local aCubos := {}
dbSelectArea("AL1")
dbSetOrder(1)
dbSeek(xFilial("AL1"))

While AL1->(!Eof() .And. AL1_FILIAL==xFilial("AL1"))

	oTree:AddTree(PadR(Alltrim(AL1->AL1_CONFIG+"-"+AL1->AL1_DESCRI),60),"PCOCUBE","PCOCUBE","AL1"+&(IndexKey()), {|| }, {|| }, {|| })

   	dbSelectArea("AKW")
    dbSetOrder(1)
   	dbSeek(xFilial("AKW")+AL1->AL1_CONFIG)
    While AKW->(!Eof() .And. AKW_FILIAL+AKW_COD==xFilial("AKW")+AL1->AL1_CONFIG)
		oTree:AddTreeItem( Alltrim(AKW->(AKW_NIVEL+"-"+AKW_CONCDE)), "TRIRIGHT", "AKW"+&(IndexKey()), {|| RunPlanej(oTree:GetCargo(),'',ALV->(Recno()))},{|| },{|| } )
 	    AKW->(dbSkip())
	End()
	oTree:EndTree()
	dbSelectArea("AL1")
    AL1->(dbSkip())

End    	
Return

Function RunPlanej(cSeek,cFilSLQ,nRecnoALV)

Local nMax,nMin
Local cQuery 	:= ''
Local cCube		:= SubStr(cSeek,6)
Local nX
Local aRet 

Default cFilSLQ		:= ''

If aConfigs[1]<>nil
	nTpGraf	:= Val(SubStr(aConfigs[1],1,2))
EndIf

DbSelectarea("ALV")
DbGoTo(nRecnoALV)

aRet 		:= PcoRunFluxo(SubStr(cSeek,6,2),SubStr(cSeek,8,2),ALV_CODIGO,'',.T.,.T.)

aDatFluxo   := aClone(aRet[5])
aCampos		:= aClone(aRet[4])

oGraphic :=  TMSGraphic():New(0,0,oFluxo:oArea:GetPanel( "WIN4" ), , /*[anClrText]*/,/* [anClrBack]*/,400,200)
oGraphic:Align := CONTROL_ALIGN_ALLCLIENT	
oGraphic:SetMargins( 0, 10, 10,10 )
oGraphic:SetGradient( GDBOTTOMTOP, CLR_HGRAY, CLR_WHITE )
oGraphic:SetTitle( "", "" , CLR_BLACK , A_LEFTJUST , GRP_TITLE )
oGraphic:SetLegenProp( GRP_SCRRIGHT, CLR_WHITE, GRP_SERIES, .T. )
oGraphic:l3D := .F.
oGraphic:lAxisVisib     := .T.      // Mostra os eixos

// Detela Series
If aSeries[1]<>nil
	oGraphic:DelSerie ( aSeries[1] )
	oGraphic:DelSerie ( aSeries[2] )	
	oGraphic:DelSerie ( aSeries[3] )	
EndIf

aSeries 	:= {nil,nil,nil}

//nMax 		:= 0
//nMin 		:= 10000000000
//nSaldo		:= 0 // Saldo inicial

aSeries[1] 	:= oGraphic:CreateSerie( nTpGraf, "Entradas")
aSeries[2] 	:= oGraphic:CreateSerie( nTpGraf, "Saidas  ")
aSeries[3] 	:= oGraphic:CreateSerie( nTpGraf, "Saldo   ")

// Monta Grafico de Dadas 
For nX:=1 To Len(aDatFluxo)

	oGraphic:add(aSeries[1], aDatFluxo[nX,2], aDatFluxo[nX,1], CLR_BLUE		)
	oGraphic:add(aSeries[2], aDatFluxo[nX,3], aDatFluxo[nX,1], CLR_RED		)
	oGraphic:add(aSeries[3], aDatFluxo[nX,4], aDatFluxo[nX,1], CLR_YELLOW	)

Next

/*
// Para o Ultimo Nivel Tipo de saldo mostra as Datas no Browse
If lMes .and. !lDrilDrow

	AEval(aCampos	, {|x,y| aEval(x[6], {|z| aAdd(aBakCamp,z) }) })
	aCampos := aBakCamp

EndIf
*/

//oGraphic:SetRangeY(nMin-100, nMax+100)

If Len(aCampos)=0
	aCampos:= {{'','',0,0,0,''}}
EndIf
//oFluxo:aObjetos[oFluxo:GetBrw("001"),2]:blDblClick := { || If(!Empty(aCampos[oFluxo:aObjetos[oFluxo:GetBrw("001"),2]:nat,6]),PCOC490(aCampos[oFluxo:aObjetos[oFluxo:GetBrw("001"),2]:nat,6],aCampos[oFluxo:aObjetos[oFluxo:GetBrw("001"),2]:nat,7],aNivel,.F.),) }

oFluxo:GetBrw("001"):SetArray(aCampos)
oFluxo:GetBrw("001"):bLine := {|| aCampos[oFluxo:GetBrw("001"):nAt] }
oFluxo:GetBrw("001"):Refresh()
    
Return



Function PcoRunFluxo(cCodCube,nNivel,cPlanej,cFilSLQ,lSald,lProjeta)

Local cQuery
Local nX,nI
Local lMes := .F.
Local aListData
Local lContinua 	:= .T.
Local cEntidade		:= ''
Local aEntidades	:= {}
Local aDatas		:= {}
Local nTotSaid		:= 0
Local nTotEntr		:= 0
Local nSaldo		:= 0
Local aRet			:= {nil	, nil , nil , {} , {} } // { Cubo, nivel , lFimCubo , aEntidades , aDatas }
//*********************************************************************
// aEntidades {Entidade , Descrição , Entrada   ,Saida   , Saldo , Filtro , Titulo }   *
// aDatas     {Data     , Entrada   ,Saida   	, Saldo  }            *
//*********************************************************************

Default nNivel 		:= ''
Default lSald		:= .F. // Calcula Saldo
Default lProjeta    := .F. // Projeto Fluxo de Caixa por Condição de Pagamento

// Valida Planilha
DbSelectArea("ALV")
DbSetOrder(1)
If !DbSeek(xFilial("ALV")+cPlanej)

	lContinua := .F.

EndIf

aListData := PcoRetPer(ALV->ALV_INIPER,ALV->ALV_FIMPER,ALV->ALV_TPPERI,.F.)
aEval(aListData,{|x| 	aAdd(aDatas , { SubStr(x,1,8) , 0 , 0 , 0 }) })

// valida Cubo
DbSelectArea("AKW")
DbSetorder(1)
If !DbSeek(xFilial("AKW")+cCodCube+nNivel)
	
	lContinua := .F.    

Else
	If ('TPSALD' $ cCampo)
	
		lMes		:= .T.
		DbSkip(-1)
		
		If !( AKW->(AKW_FILIAL+AKW_COD)==xFilial("AKW")+cCodCube )
		
			lContinua := .F.    
		
		Else
		
			aRet[1]	:= AKW->AKW_COD
			aRet[2] := AKW->AKW_NILVEL
			aRet[3]	:= .T.
			cCampo		:= StrTran(SubStr(AKW->AKW_CHAVER,6),"AKD","ALX")
			cNextNivel 	:= ''	    

		EndIf
	
	Else
	
		aRet[1]	:= AKW->AKW_COD
		aRet[2] := AKW->AKW_NIVEL
		aRet[3]	:= .F.
		cCampo		:= StrTran(SubStr(AKW->AKW_CHAVER,6),"AKD","ALX")
		cNextNivel 	:= AKW->AKW_FILIAL+AKW->AKW_COD+Soma1(nNivel,2)	    	

	EndIf

EndIf

If lContinua

	cQuery := 'SELECT '

	If lProjeta 

		cQuery += 'ALX_CODIGO,ALX_AGREG,ALX_TIPOPL, '

	EndIf
	cQuery += cCampo+","+SubStr(AKW->AKW_DESCRE,6)+","
	cQuery += "ALY_DTINI "
	
	// Totaliza as Entrada e Saidas pela competencia
	If !lProjeta
	  
		cQuery += ",SUM(CASE WHEN ALX_TIPOPL IN ('001','002','003','004') THEN ALY_VALOR ELSE 0 END) AS ENTRADA "
		cQuery += ",SUM(CASE WHEN ALX_TIPOPL='005' THEN ALY_VALOR ELSE 0 END) AS SAIDA "
	
	Else
	
		cQuery += ",SUM(ALY_VALOR) AS ALY_VALOR "
	
	EndIf
	
	cQuery += "FROM " + RetSqlName("ALY") + " ALY," + RetSqlName("ALX") + " ALX, " + RetSqlName(AKW->AKW_ALIAS) +  " "+ AKW->AKW_ALIAS
	cQuery += " WHERE ALY.D_E_L_E_T_=' ' AND ALX.D_E_L_E_T_=' ' AND "+AKW->AKW_ALIAS+".D_E_L_E_T_=' ' AND ALY_FILIAL='"+xFilial("ALY")+"' AND ALY_FILIAL=ALX_FILIAL AND ALY_SEQ=ALX_SEQ "
	cQuery += If(Empty(xFilial(AKW->AKW_ALIAS)),"","AND "+AKW->AKW_ALIAS+"_FILIAL=ALY_FILIAL")
	cQuery += " AND ALX_PLANEJ='"+ALV->ALV_CODIGO+"' AND ALY_PLANEJ=ALX_PLANEJ"
	cQuery += " AND "+SubStr(AKW->AKW_RELAC,6)+"="+cCampo+ " "

	If cFilSLQ<>''

		cQuery += " AND "+cFilSLQ

	EndIf

	cQuery += ' GROUP BY '
	If lProjeta
		cQuery += 'ALX_CODIGO,ALX_AGREG,ALX_TIPOPL, '
	EndIf
	cQuery += cCampo+","+SubStr(AKW->AKW_DESCRE,6)+",ALY_DTINI"

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPFLU", .T., .T. )
	DbSelectArea("TMPFLU")
	DbGoTop()

	Do While TMPFLU->(!Eof())

		If cEntidade<>TMPFLU->(&cCampo)
	
			cEntidade 	:= TMPFLU->(&cCampo)
			dbSelectArea("SX3")
			dbSetOrder(2)
			dbSeek(cCampo)

			aAdd(aEntidades , 	{ TMPFLU->(&cCampo) 	, TMPFLU->(&(SubStr(AKW->AKW_DESCRE,6))), 0 	, 0 	, 0 	,cNextNivel	, cCampo+"='" +TMPFLU->(&cCampo)+"' " 	, ALLTRIM(x3Titulo()) +" - "+TMPFLU->(&cCampo) })
			//	 aEntidades 	{Entidade 				, Descrição 							, Ent	,Saida  , Saldo ,cNextNivel	,			Filtro						,		Titulo									}
			nTotEntr	:= 0
			nTotSaid	:= 0
			nSaldo		:= 0
	
		EndIf
	    
		If lProjeta
			// Abre o valor
			aProjeta := PcoProjVal( If(TMPFLU->ALX_TIPOPL=='002',TMPFLU->ALX_CODIGO , TMPFLU->ALX_AGREG) , TMPFLU->ALX_TIPOPL , TMPFLU->ALY_VALOR , sTod(TMPFLU->ALY_DTINI) )

		    For nI:=1 To Len(aProjeta)
 				
 				nX := 0
 				// Localiza Datas Projetadas de acordo com a Condição de Pagamento
 				aEval(aDatas,{|x,y| If( cTod(x[1])<=aProjeta[nI,1] .and. If(Len(aDatas)>y,cTod(aDatas[y+1][1]) >= aProjeta[nI,1],.T.),nX := y,.F.) })				

			    // Soma valores
				If TMPFLU->ALX_TIPOPL$"001#002"
				
					aDatas[nX,2] += aProjeta[nI,2]
				
				Else
				
					aDatas[nX,3] += aProjeta[nI,2]
				
				Endif
				
				aDatas[nX,4] += 0  

		    Next 
		Else
			// totaliza Saldo nas Datas
			If ( nX := aScan(aDatas,{|x|x[1]=dToc(sTod(TMPFLU->ALY_DTINI))} )) ==0
	
				// Adiciona Meses para cada Entidade
				aAdd(	aDatas,{ dToc(sTod(TMPFLU->ALY_DTINI)) 	, TMPFLU->ENTRADA 	, TMPFLU->SAIDA 	, 0 })
				// 		aDatas {Data     						, Entrada   		,Saida   			, Saldo  }
	
			Else
			    // Soma valores
				aDatas[nX,2] += TMPFLU->ENTRADA
				aDatas[nX,3] += TMPFLU->SAIDA
				aDatas[nX,4] += 0
			
			EndIf
		EndIf		
		// Totalizadores da Entidade
		nTotEntr	+= TMPFLU->ENTRADA
		nSaldo		+= TMPFLU->ENTRADA
	
		nTotSaid	+= TMPFLU->SAIDA
		nSaldo		-= TMPFLU->SAIDA
		
		TMPFLU->(DbSkip())
		If cEntidade<>TMPFLU->(&cCampo)

			// Preenche valores do item da entidade anterior
			aEntidades[Len(aEntidades),3] 	:= nTotEntr
			aEntidades[Len(aEntidades),4]	:= nTotSaid
			aEntidades[Len(aEntidades),5]	:= nSaldo
		
		EndIf
	EndDo

	If lSald // Calcula Saldo
		nSaldo := 0
		aEval( aDatas , {|x,y| (nSaldo := (x[4] := nSaldo + (x[2]-x[3]) ) )  })
	EndIf

TMPFLU->(DbCloseArea())

If lMes .and. lDrilDrow
	aRet[4] := aClone(aDatas	)
Else
	aRet[4] := aClone(aEntidades)	
EndIf
aRet[5] := aClone(aDatas	)

EndIf


Return aRet


// Abre o Valor de acordo com a Condição de Pagamento configurada
Static Function PcoProjVal( cAgreg , cTipoPlan , nValor,dData )

Local aRet 	:= {} 
Local lOk	:= .F.
Local cCond	:= ''
Do Case 

	Case cTipoPlan$'001#002'
		DbSelectArea('SB1')
		DbSetOrder(1)
		If DbSeek(xFilial("SB1")+cAgreg)

			If FieldPos("B1_CONDVEN")>0 .AND. !Empty(SB1->B1_CONDVEN)
				cCond := SB1->B1_CONDVEN
				lOk := .T.

			ElseIf !Empty(SB1->B1_PROC)

				DbSelectArea("SA2")
				DbSetOrder(1)

				If DbSeek(xFilial("SA2")+SB1->B1_PROC) .and. !Empty(SA2->A2_COND)
					cCond := SA2->A2_COND
					lOk := .T.

				EndIf
			Else

				DbSelectArea("AM1")
				DbSetOrder(1)

				If DbSeek(xFilial("AM1")+cTipoPlan)

					If FieldPos("AM1_COND")>0 .and. !Empty(AM1->AM1_COND)
						cCond := AM1->AM1_COND
						lOk := .T.						

					EndIf

				EndIf
	
			EndIf
		EndIf

	Case cTipoPlan = '005'

		DbSelectArea('ALT')
		DbSetOrder(1)
		If DbSeek(xFilial("ALT")+cAgreg)

			If FieldPos("ALT_COND")>0 .AND. !Empty(ALT->ALT_COND)
				cCond := ALT->ALT_COND
				lOk := .T.

			Else
				DbSelectArea("AM1")
				DbSetOrder(1)

				If DbSeek(xFilial("AM1")+cTipoPlan)

					If FieldPos("AM1_COND")>0 .and. !Empty(AM1->AM1_COND)
						cCond := AM1->AM1_COND
						lOk := .T.						

					EndIf

				EndIf

			EndIf

		EndIf

EndCase
if lOk
	aRet := Condicao(nValor,cCond,0,dData)
Else
	aRet := {{dData,nValor}}
EndIf
Return (aRet)