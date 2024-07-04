#INCLUDE "PCOC330.ch"
#include "protheus.ch"
#include "msgraphi.ch"

#DEFINE N_COL_VALOR	 2

/*/
_F_U_N_C_����������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���FUNCAO    � PCOC330  � AUTOR � Edson Maricate        � DATA � 26.11.2003 ���
���������������������������������������������������������������������������Ĵ��
���DESCRICAO � Programa de Consulta ao arquivo de saldos mensais dos Cubos  ���
���������������������������������������������������������������������������Ĵ��
��� USO      � SIGAPCO                                                      ���
���������������������������������������������������������������������������Ĵ��
���_DOCUMEN_ � PCOC330                                                      ���
���_DESCRI_  � Programa de Consulta ao arquivo de saldos mensair dos Cubos  ���
���_FUNC_    � Esta funcao podera ser utilizada com a sua chamada normal    ���
���          � partir do Menu ou a partir de uma funcao pulando assim o     ���
���          � browse principal e executando a chamada direta da rotina     ���
���          � selecionada.                                                 ���
���          � Exemplo: PCOC330(2) - Executa a chamada da funcao de visua-  ���
���          �                       zacao da rotina.                       ���
���������������������������������������������������������������������������Ĵ��
���_PARAMETR_� ExpN1 : Chamada direta sem passar pela mBrowse               ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function PCOC330(nCallOpcx,dData,aFilIni,aFilFim,lZerado)

Local bBlock
Local nPos
Private cCadastro	:= STR0001 //"Consulta Saldos na Data - Cubos"
Private aRotina := MenuDef()
Private cArqAKT

If nCallOpcx <> Nil
	nPos := Ascan(aRotina,{|x| x[4]== nCallOpcx})
	If ( nPos # 0 )
		bBlock := &( "{ |x,y,z,k,w,a,b,c,d,e,f,g| " + aRotina[ nPos,2 ] + "(x,y,z,k,w,a,b,c,d,e,f,g) }" )
		Eval( bBlock,Alias(),AL4->(Recno()),nPos,,,,dData,aFilIni,aFilFim,lZerado)
	EndIf
Else
	If SuperGetMV("MV_PCOCNIV",.F., .F.)
		PCOC331(nCallOpcx,dData,,,lZerado)
	Else
		mBrowse(6,1,22,75,"AL1")
	EndIf	
EndIf

If GetNewPar("MV_PCOMCHV","1") == '4' .And. cArqAKT  != NIL
	MsErase(cArqAKT)
EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Pco330View�Autor  �Edson Maricate      � Data �  24/05/05   ���
�������������������������������������������������������������������������͹��
���Desc.     �funcao que solicita parametros para utilizacao na montagem  ���
���          �da grade e grafico ref. saldo gerencial do pco              ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Pco330View(cAlias,nRecno,nOpcx,xRes1,xRes2,xRes3,dData,aFilIni,aFilFim,lZerado)
Local aProcessa := {}
Local nTpGraph
Local nX, nY, nZ
Local aNiveis	 := {}
Local aCfgAuxCube := {}
Local aAuxCube := {}
Local cSerAux := PadR(STR0035+"1",30)//"Serie "
Local aListArq := {}
Local aTpGrafico

//***********************************************
// Implemantacao do Grafico com FwChartFactory  *
//***********************************************
Private lNewGrafic := SuperGetMV("MV_PCOTPGR",.F.,2) == 1 .and. FindFunction("__FWCBCOMP")
 // parametro que informa qual objeto grafico sera utilizado 1= fwChart qquer outra informacao = msGraphic

If lNewGrafic

	aTpGrafico:= {STR0004,; //"1=Linha"
					"2="+SubStr(STR0007,3)}//"4=Barra"

Else
	aTpGrafico:= {STR0004,; //"1=Linha"
								STR0005,; //"2=Area"
								STR0006,; //"3=Pontos"
								STR0007   ,; //"4=Barra"
								STR0008  ,; //"5=Piramide"
								STR0009    ,; //"6=Cilindro"
								STR0010,; //"7=Barra Horizontal"
								STR0011,; //"8=Piramide Horizontal"
								STR0012,; //"9=Cilindro Horizontal"
								STR0013,; //"10=Pizza"
								STR0014,; //"11=Forma"
								STR0015,; //"12=Linha Rapida"
								STR0016,; //"13=Flechas"
								STR0017,; //"14=Gantt"
								STR0018 } //"15=Bolha"
EndIf

Private aConfig := {}
Private aCfgSec := {}
Default dData	 := dDataBase

Private COD_CUBO  := AL1->AL1_CONFIG
Private nNivInic  := 1

If ParamBox({ { 1 ,STR0019,Space(LEN(AL3->AL3_CODIGO))		  ,"@!" 	 ,""  ,"AL3" ,"" ,25 ,.F. },; //"Config Cubo"
					{ 3,STR0020,1,{STR0021,STR0022},40,,.F.},; //"Exibe Configura��es"###"Sim"###"Nao" 
					{ 1,STR0036,cSerAux,"@!" 	 ,""  ,"" ,"" ,75 ,.F. },; //"Descri��o S�rie"
					{ 1,STR0023,dData,"" 	 ,""  ,""    ,"" ,50 ,.F. },; //"Saldo em"
					{ 2,STR0024,4,aTpGrafico,80,"",.F.},; // "Tipo do Grafico"
					{ 1,STR0037, 2,"99" 	 ,"pco330Ser()"  ,"" ,"" ,15 ,.F. },; // "Qtde de Series"
					{ 3,STR0044, 1,{STR0021,STR0022},40,,.F.} },STR0025,aConfig,,,,,, , "PCOC330_01", ,.T.) //"Exibe Totais"###"Sim"###"Nao"

    aCfgSec := C330Cfg()
    
	aProcessa := PcoRunCube(AL1->AL1_CONFIG,aConfig[6]/*1*/,"PcoC330Sld",aConfig[1],aConfig[2],lZerado,aNiveis,aFilIni,aFilFim,NIL /*lRetOriCod*/,aAuxCube,/*lProcessa*/,.T./*lVerAcesso*/,/*lForceNoSint*/,/*aItCfgBlq*/,/*aFiltCfg*/,@cArqAKT, .F./*llimpArqAKT*/)
	aAdd(aCfgAuxCube, aClone(aAuxCube))

    If Len(aProcessa) > 0
	    For nX := 2 TO aConfig[6]
			a_AuxProcessa := {}
			a_AuxProcessa := PcoRunCube(AL1->AL1_CONFIG,1,"PcoC330Sd1",aCfgSec[((nX-1)*3)-2],aConfig[2],lZerado,aClone(aNiveis),aFilIni,aFilFim,NIL /*lRetOriCod*/,aAuxCube,/*lProcessa*/,.T./*lVerAcesso*/,/*lForceNoSint*/,/*aItCfgBlq*/,/*aFiltCfg*/,@cArqAKT, .F./*llimpArqAKT*/)
			aAdd(aCfgAuxCube, aClone(aAuxCube))
			//transportar os dados para aProcessa
			If Len(a_AuxProcessa) > 0
			    For nY := 1 TO Len(a_AuxProcessa)
			    	nPos := Ascan(aProcessa, {|aVal| aVal[1] == a_AuxProcessa[nY][1]})
			    	If nPos > 0
				    	
				    	aProcessa[nPos][2][nX] := a_AuxProcessa[nY][2][1]
				    	
				    Else
				    	
						aAdd(aProcessa, aClone(a_AuxProcessa[nY]))
						
						aProcessa[Len(aProcessa)][2] := {}   //coloca um array vazio e popula zerado
						For nZ := 1 TO aConfig[6]
							aAdd(aProcessa[Len(aProcessa)][2], 0)
						Next
						aProcessa[Len(aProcessa)][2][nX] += a_AuxProcessa[nY][2][1]
					EndIf
		    	Next
		    EndIf
		Next
	EndIf
	
	If !Empty(aProcessa)
		nTpGraph  := If(ValType(aConfig[5])=="N", aConfig[5], Val(aConfig[5]))
		nNivInic  := aNiveis[1]
		PCOC330PFI(aProcessa,nNivInic,,nTpGraph,aNiveis,1,NIL/*cDescrChv*/,NIL/*cChaveOri*/,aCfgAuxCube,,,aListArq)
	Else
		Aviso(STR0026,STR0027,{STR0028},2) //"Aten��o"###"N�o existem valores a serem visualizados na configura��o selecionada. Verifique as configura��es da consulta."###"Fechar"
	EndIf
					
EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PcoC330Sld�Autor  �Edson Maricate      � Data �  24/05/05   ���
�������������������������������������������������������������������������͹��
���Desc.     �funcao utilizada na rotina de processamento do cubo         ���
���          �gerencial do pco                                            ���
���          �Grava o valor da confg inicial e zera os valores das demais,���
���          �portanto se alterar tb PCOC330SD1                           ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PcoC330Sld(cConfig,cChave)
Local aRetFim
Local nCrdFim
Local nDebFim
Local aRet
Local nx

aRetFim := PcoRetSld(cConfig,cChave,aConfig[4])
nCrdFim := aRetFim[1, 1]
nDebFim := aRetFim[2, 1]

nSldFim := nCrdFim-nDebFim

aRet := {}
aAdd(aRet, nSldFim)
For nX := 1 TO (aConfig[6]-1)
	aAdd(aRet, 0)
Next
	
Return aRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PcoC330Sld�Autor  �Edson Maricate      � Data �  24/05/05   ���
�������������������������������������������������������������������������͹��
���Desc.     �funcao utilizada na rotina de processamento do cubo         ���
���          �gerencial do pco                                            ���
���          �Nesta rotina grava as configuracoes alem da inicial         ���
���          �portanto se alterar esta funcao alterar tb PCOC330Sld       ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PcoC330Sd1(cConfig,cChave)
Local aRetFim
Local nCrdFim
Local nDebFim

aRetFim := PcoRetSld(cConfig,cChave,aConfig[4])
nCrdFim := aRetFim[1, 1]
nDebFim := aRetFim[2, 1]

nSldFim := nCrdFim-nDebFim

Return {nSldFim}


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PCOC330PFI�Autor  �Edson Maricate      � Data �  24/05/05   ���
�������������������������������������������������������������������������͹��
���Desc.     �funcao que processa o cubo gerencial do pco e exibe uma     ���
���          �grade com o grafico                                         ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function PCOC330PFI(aProcessa,nNivel,cChave,nTpGrafico,aNiveis,nCall,cDescrChv,cChaveOri,aCfgAuxCube,cClasse, lShowGraph,aListArq)

Local oDlg, oPanel, oPanel1, oPanel2
Local oView
Local oGraphic
Local aArea		:= GetArea()
Local cAlias
Local nRecView
Local nStep
Local dx
Local nSerie
Local cTexto
Local aSize     := {}
Local aPosObj   := {}
Local aObjects  := {}
Local aInfo     := {}
Local aView		:= {}
Local aChave 	:= {}
Local aChaveOri:= {}
Local nNivCub	:= 0
Local nx
Local cDescri	:= ""
Local aButtons  := {}
Local bEncerra := {|| If(nNivel>nNivInic,oDlg:End(),If(Aviso(STR0029,STR0030, {STR0021, STR0022},2)==1, ( PcoArqSave(aListArq), oDlg:End() ), NIL))} //"Atencao"###"Deseja abandonar a consulta ?"###"Sim"###"Nao"
Local aTabMail	:=	{}
Local cFiltro
Local ny
Local nColor := 1
Local aParam	:=	{"",.F.,.F.,.F.}
Local aSeries	:= {}
Local aTotSer	:= {}
Local nz
Local lClassView := .F.                             
Local nLenView	 := 0
Local lPergNome  := ( SuperGetMV("MV_PCOGRAF",.F.,"2") == "1" )
Local aSerie2	:= {}

DEFAULT cDescrChv := ""
DEFAULT cChave := ""
DEFAULT cChaveOri := ""
DEFAULT lShowGraph := .T.
DEFAULT aListArq := {}

If nCall+1 <= Len(aNiveis)
	aButtons := {	{"PMSZOOMIN"	,{|| Eval(oView:blDblClick) },STR0031 ,STR0032},; //"Drilldown do Cubo"###"Drilldown"
						{"BMPPOST"  ,{|| PmsGrafMail(oGraphic,Padr(cDescri,150),{cCadastro },aTabMail, NIL, 2, .T.) },STR0033,STR0034 },; //"Enviar Emial"###"Email"
						{"GRAF2D"   ,{|| HideShowGraph(oPanel2, oPanel1, @lShowGraph) },STR0046,STR0047 },; //"Exibir/Esconder Grafico"###"Grafico"
						{"SALVAR"	,{|| PcoSaveGraf(oGraphic, lPergNome, .T., .F., aListArq) },STR0049,STR0050 },; //"Imprimir/Gerar Grafico em formato BMP"##"Salva/BMP"
						{"PESQUISA" ,{|| PcoConsPsq(aView,.F.,@aParam,oView) },STR0002,STR0002 },; //Pesquisar
						{"E5"       ,{|| PcoConsPsq(aView,.T.,@aParam,oView) },STR0043 ,STR0043 }; //Pesquisa
					}
Else
	aButtons := {	{"PMSZOOMIN",{|| Eval(oView:blDblClick) },STR0031 ,STR0032},;//"Drilldown do Cubo" ,"Drilldown"
						{"BMPPOST"  ,{|| PmsGrafMail(oGraphic,Padr(cDescri,150),{cCadastro },aTabMail, NIL, 2, .T.) },STR0033,STR0034 },; //"Enviar Emial"###"Email"
						{"GRAF2D"   ,{|| HideShowGraph(oPanel2, oPanel1, @lShowGraph)},STR0046,STR0047 },; //"Exibir/Esconder Grafico"###"Grafico"
						{"SALVAR"	,{|| PcoSaveGraf(oGraphic, lPergNome, .T., .F., aListArq) },STR0049,STR0050 },; //"Imprimir/Gerar Grafico em formato BMP"##"Salva/BMP"
						{"PESQUISA" ,{|| PcoConsPsq(aView,.F.,@aParam,oView) },STR0002,STR0002 },; //Pesquisar
						{"E5"       ,{|| PcoConsPsq(aView,.T.,@aParam,oView) },STR0043 ,STR0043 }; //Pesquisa
					}
EndIf					

aTitle := {cDescri,STR0038, aConfig[3]} //"Descricao"
For nx := 2 TO aConfig[6]
	aAdd(aTitle, aCfgSec[((nX-1)*3)])
Next	

aAdd(aTabMail,{})
For nx := 1 to Len(aTitle)
	aAdd(aTabMail[Len(aTabMail)],aTitle[nx])
Next

For nx := 1 to Len(aProcessa)
	If aProcessa[nx,8] == nNivel .And. (/*Empty(cChave) .Or. */Padr(aProcessa[nx,1],Len(cChave))==cChave)
		cDescri := AllTrim(aProcessa[nx,5])
		aAdd(aView,{Substr(aProcessa[nx,1],Len(cChave)+1),aProcessa[nx,6]})
		If aConfig[7] == 1 .And. !aProcessa[nx,10]
			aAdd(aTotSer,Array(Len(aProcessa[nx,2])))
			aFill(aTotSer[Len(aTotSer)],0)
		EndIf	
		For ny := 1 to Len(aProcessa[nx,2])
			aAdd(aView[Len(aView)], aProcessa[nx,2,ny])
			If aConfig[7] == 1 .And. !aProcessa[nx,10]
				aTotSer[Len(aTotSer),ny] += aProcessa[nx,2,ny]
			EndIf	
		Next	
		aAdd(aChave,{aProcessa[nx,1]})
		aAdd(aChaveOri,{aProcessa[nx,9]})
		aadd(aTabMail,{Substr(aProcessa[nx,1],Len(cChave)+1),PadR(aProcessa[nx,6],50)})
		For ny := 1 to Len(aProcessa[nx][2])
			aAdd(aTabMail[Len(aTabMail)], Alltrim(TransForm(aProcessa[nx][2][ny],'@E 999,999,999,999.99')))
		Next	      		
		If aProcessa[nx,4] == 'AK6'
			lClassView := .T.
		Endif
	EndIf
Next

C340MontaFiltro(AL1->AL1_CONFIG, @cFiltro, aCfgAuxCube, 1/*nSerie*/, nNivel, "PCOC330")

If !Empty(aView)
               
	aView := aSort( aView,,, { |x,y| x[1] < y[1] } )
	aChave := aSort( aChave,,, { |x,y| x[1] < y[1] } )
	aChaveOri := aSort( aChaveOri,,, { |x,y| x[1] < y[1] } )

	If aConfig[7] == 1	// Exibe totais das series
		If Len(aTotSer) == 0
			// Atencao ### Foram encontradas inconsist�ncias entre os movimentos e o cadastro do primeiro n�vel do cubo. O total das s�ries n�o ser� exibido.
			Aviso( STR0029, STR0048, {STR0028})
			aConfig[7] := 2
		Else
			AAdd( aView, { STR0045, "" } ) // TOTAL
			aAdd(aTabMail,{ STR0045, Space(50) } ) // TOTAL
		          
			nLenView := Len(aView)
		
			For nx := 1 to Len(aTotSer[1])
				AAdd( aView[nLenView], 0 )
				AAdd( aTabMail[Len(aTabMail)], Alltrim(Transform(0, "@E 999,999,999,999.99")) )
			Next nx
		
			For nx := 1 to Len(aTotSer)
				For ny := 1 to Len(aTotSer[nx])
					aView[nLenView,ny+N_COL_VALOR] += aTotSer[nx,ny]
				Next ny
			Next nx

			For nx := 1+N_COL_VALOR to Len(aView[nLenView])
				aTabMail[Len(aTabMail), nX] := Alltrim(Transform(aView[nLenView, nX], "@E 999,999,999,999.99"))
            Next


		EndIf	
	EndIf
		
	aSize := MsAdvSize(,.F.,400)
	aObjects := {}
	
	AAdd( aObjects, { 100, 100 , .T., .T. } )
	
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 2, 2 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )
	
	DEFINE FONT oBold NAME "Arial" SIZE 0, -11 BOLD
	DEFINE FONT oFont NAME "Arial" SIZE 0, -10 
	DEFINE MSDIALOG oDlg TITLE cCadastro + " - "+cDescri From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
	oDlg:lMaximized := .T.
	
	
	oPanel := TPanel():New(0,0,'',oDlg, , .T., .T.,, ,10,If(Empty(cDescrChv),0,11+((nNivel-1)*11)),.T.,.T. )
	oPanel:Align := CONTROL_ALIGN_TOP

	oPanel1 := TPanel():New(0,0,'',oDlg, , .T., .T.,, ,40,40,.T.,.T. )
	oPanel1:Align := CONTROL_ALIGN_ALLCLIENT

	oPanel2 := TPanel():New(0,0,'',oDlg, , .T., .T.,, ,40,120,.T.,.T. )
	oPanel2:Align := CONTROL_ALIGN_BOTTOM
	If !lShowGraph
		oPanel2:Hide()
	EndIf	

	@ 3,2 MSGRAPHIC oGraphic SIZE aPosObj[1,4]-10,aPosObj[1,3]-aPosObj[1,1]-30 OF oPanel2
	oGraphic:Align := CONTROL_ALIGN_ALLCLIENT
	oGraphic:oFont := oFont
	
	oGraphic:SetMargins( 20, 15, 10,10 )
	oGraphic:SetGradient( GDBOTTOMTOP, CLR_HGRAY, CLR_WHITE )
	oGraphic:SetTitle( "", "" , CLR_BLACK , A_LEFTJUST , GRP_TITLE )
	oGraphic:SetLegenProp( GRP_SCRRIGHT, CLR_WHITE, GRP_SERIES, .F. )
	
	For nx := 1 TO aConfig[6]
		aAdd(aSeries,Nil	)
		aSeries[Len(aSeries)] := oGraphic:CreateSerie( If(lNewGrafic,If(nTpGrafico==2,4,nTpGrafico),nTpGrafico) )
	Next	

	For nx := 1 to Len(aProcessa)
		If aProcessa[nx,8] == nNivel .And. (/*Empty(cChave) .Or. */Padr(aProcessa[nx,1],Len(cChave))==cChave)
			For ny := 1 TO Len(aProcessa[nx][2])
				oGraphic:Add(aSeries[ny], Round(aProcessa[nx][2][ny],2) ,Substr(aProcessa[nx,1],Len(cChave)+1),C330Cores(ny))
		    Next
		EndIf
	Next    
	
	If aConfig[7] == 1		// Exibe totais das series
		nLenView := Len(aView)
		For nx := 3 to Len( aView[nLenView] )
			oGraphic:Add(aSeries[nx-N_COL_VALOR], Round(aView[nLenView,nx],2) ,STR0045,C330Cores(nx-N_COL_VALOR))	// TOTAL
		Next nx
	EndIf
	
	oGraphic:l3D := .F.

	If lNewGrafic
		
		//oGraphic:Hide()
		//***********************************************
		// Implemantacao do Grafico com FwChartFactory  *
		//***********************************************
		// Monta Series
		aAdd(aSerie2, aConfig[3] )
		For ny := 2 to aConfig[6]
			aAdd(aSerie2, aCfgSec[((ny-1)*3)] )
		Next
		
		PcoGrafDay(aProcessa,nNivel,cChave,oPanel2,nTpGrafico,aSerie2, (aConfig[7] == 1) ,aTotSer)
	
	EndIf

	@ 2,4 SAY STR0032 of oPanel SIZE 120,9 PIXEL FONT oBold COLOR RGB(80,80,80)//"Drilldown"
	@ 3,3 BITMAP oBar RESNAME "MYBAR" Of oPanel SIZE BrwSize(oDlg,0)/2,8 NOBORDER When .F. PIXEL ADJUST

	@ 12,2   SAY cDescrChv Of oPanel PIXEL SIZE 640 ,79 FONT oBold

	oView	:= TWBrowse():New( 2,2,aPosObj[1,4]-6,aPosObj[1,3]-aPosObj[1,1]-16,,aTitle,,oPanel1,,,,,,,oFont,,,,,.F.,,.T.,,.F.,,,)
	oView:Align := CONTROL_ALIGN_ALLCLIENT
	oView:SetArray(aView)
                                     
	If nCall+1 <= Len(aNiveis)
		oView:blDblClick := { || IIf( PcocChkTot(aConfig,aView,oView),PCOC330PFI(aProcessa,aNiveis[nCall+1],aChave[oView:nAT,1],nTpGrafico,aNiveis,nCall+1,IF(!Empty(cDescrChv),cDescrChv+CHR(13)+CHR(10),"")+Str(nNivel,2,0)+". "+Alltrim(cDescri)+" : "+AllTrim(aView[oView:nAT,1])+" - "+AllTrim(aView[oView:nAT,2]),aChaveOri[oView:nAT,1],aCfgAuxCube,If(lClassView,aView[oView:nAT,1],cClasse), @lShowGraph, aListArq), .T. ) }
	Else
		oView:blDblClick := { || IIf( PcocChkTot(aConfig,aView,oView),	(C340MontaFiltro(AL1->AL1_CONFIG, @cFiltro, aCfgAuxCube, 1/*nSerie*/, nNivel, "PCOC330"), Pcoc330lct(cFiltro+aChaveOri[oView:nAT,1]+'"',.T.)),.T.)}
	EndIf

	If lClassView
		oView:bLine := { || PcoFrmDados(aView[oView:nAT],Nil,IIf( PcocChkTot(aConfig,aView,oView),lClassView,Nil)) }
	Else
		oView:bLine := { || PcoFrmDados(aView[oView:nAT],IIf( PcocChkTot(aConfig,aView,oView),cClasse,Nil),Nil) }
	Endif

	aButtons := aClone(AddToExcel(aButtons,{ {"ARRAY",cDescrChv,aTitle,aView} } ))

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| Eval(bEncerra)},{||Eval(bEncerra)},, aButtons)
EndIf

RestArea(aArea)

Return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Pcoc330lct  �Autor  �Edson Maricate    � Data �  04/08/05   ���
�������������������������������������������������������������������������͹��
���Descricao �Browse para Visualizacao dos lancamentos que compoem o saldo���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1 - Expressao Advpl de filtro na tabela de lancamentos  ���
���          �EXPC2 - Indicar se deve exibir mensagem de aviso caso nao   ���
���          �        encontre nenhum lancamento no filtro passado como   ���
���          �        parametro.                                          ���
�������������������������������������������������������������������������͹��
���Uso       � Consultas de detalhe do lancamento (AKD)                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Pcoc330lct(cFiltroAKD, lExibeMsg)
Local aArea			:= GetArea()
Local aAreaAKD		:= AKD->(GetArea())
Local aSize			:= MsAdvSize(,.F.,430)
Local aIndexAKD	    := {}

Private bFiltraBrw  := {|| Nil }
Private aRotina 	:= {	{STR0002,"PesqBrw"    ,0,2},;  //"Pesquisar"
							{STR0003,"c330LctView",0,2}}  //"Visualizar"

Default lExibeMsg := .F.

//������������������������������������������������������������������������Ŀ
//�Realiza a Filtragem                                                     �
//��������������������������������������������������������������������������
AKD->(DbGotop())
bFiltraBrw := {|| FilBrowse("AKD",@aIndexAKD,@cFiltroAKD) }
Eval(bFiltraBrw)

If AKD->( EoF() )
	If lExibeMsg 
		Aviso(STR0029,STR0042,{"Ok"})		// Atencao ### N�o existem lan�amentos para compor o saldo deste cubo.
	EndIf	
Else
	mBrowse(aSize[7],0,aSize[6],aSize[5],"AKD")
//	MaWndBrowse(aSize[7],0,aSize[6],aSize[5],cCadastro,"AKD",,aRotina,,,,.F.,,,,,,,,.F.)
EndIf

//������������������������������������������������������������������������Ŀ
//�Restaura as condicoes de Entrada                                        �
//��������������������������������������������������������������������������
EndFilBrw("AKD",aIndexAKD)

RestArea(aAreaAKD)
RestArea(aArea)
Return 


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �c330LctView �Autor  �Edson Maricate    � Data �  04/08/05   ���
�������������������������������������������������������������������������͹��
���Desc.     �Visualizacao do lancamento                                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function c330LctView()
Local aArea	:= GetArea()
Local aAreaAKD	:= AKD->(GetArea())

PCOA050(2)

RestArea(aAreaAKD)
RestArea(aArea)
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �C330Cores �Autor  �Paulo Carnelossi    � Data �  25/10/05   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna cor para montagem do grafico - para cada serie e    ���
���          �definida uma cor                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function C330Cores(nX)
Local	aCores := { CLR_BLUE, ;
					CLR_CYAN, ;
					CLR_GREEN, ;
					CLR_MAGENTA, ;
					CLR_RED, ;
					CLR_BROWN, ;
					CLR_HGRAY, ;
					CLR_LIGHTGRAY, ;
					CLR_BLACK}
If nX < Len(aCores)
	nCor := aCores[nX]
Else
	nCor := C330Cores(nX/Len(aCores))
EndIf

Return nCor

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �C330Cfg() �Autor  �Paulo Carnelossi    � Data �  25/10/05   ���
�������������������������������������������������������������������������͹��
���Desc.     �Monta parambox para digitacao das configuracoes de cubos a  ���
���          �ser comparada graficamente com a cfg inicial                ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function C330Cfg()
Local aCfgCub := {}
Local aCuboCfg := {}
Local nX
For nX := 1 TO (aConfig[6]-1)
	&("MV_PAR"+AllTrim(STRZERO((nX*3)-2,2,0)	)	) := Space(LEN(AL4->AL4_CODIGO))
	&("MV_PAR"+AllTrim(STRZERO((nX*3)-1,2,0))) := 1
	aAdd(aCuboCfg, { 1  ,STR0039+Str(nX+1, 2,0),Space(LEN(AL3->AL3_CODIGO))		  ,"@!" 	 ,''  ,"AL3" ,"" ,25 ,.F. }) //"Config.Cubo Serie"
	aAdd(aCuboCfg, { 3 ,STR0040,1,{STR0021,STR0022},40,,.F.}) //"Exibe Configura��es"###"Sim"###"Nao"
	aAdd(aCuboCfg, { 1  ,STR0036,PadR(STR0035+Str(nx+1,2,0),30),"@!" 	 ,""  ,"" ,"" ,75 ,.F. })//"Descri��o S�rie"###"Serie "
Next

If Len(aCuboCfg) > 0
	ParamBox(aCuboCfg, STR0041, aCfgCub,/*bOk*/,/*aButtons*/,/*lCentered*/,/*nPosx*/,/*nPosy*/, /*oDlgWizard*/, "PCOC330_02"/*cArqParam*/,,.T.) //"Configuracao de Cubos"
EndIf

Return aCfgCub

Function PcoFilterCube()
Local lRet := .F.

If Type("COD_CUBO") == "U" .OR. Empty(COD_CUBO)
	lRet := .T.
Else
	lRet := (AL3->AL3_CONFIG == COD_CUBO)
EndIf

Return lRet	

Function PcoFrmDados(aDados,cClasse,lClassView) 
Local aRet	:=	aClone(aDados)
LOcal nX               
DEFAULT lClassView	:=	.F.
For nX := 1 To Len(aRet)
	If ValType(aRet[nX]) == 'N'
		If lClassView
		 	aRet[nX] := PcoPlanCel(aRet[nX],aRet[1])
		ElseIf cClasse <> Nil      
		 	aRet[nX] := PcoPlanCel(aRet[nX],cClasse)
		Else
	    	aRet[nX] := TransForm(aRet[nX],'@E 999,999,999,999.99')
		Endif                                                 
		aRet[nX]	:=	PadL(aRet[nX],30)
	Endif             	
Next                                                                        
    
Return aRet
                     

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � PCOCChkTot �Autor � Gustavo Henrique   � Data �  23/05/06  ���
�������������������������������������������������������������������������͹��
���Descricao � Retornar se deve exibir o valor total das series no browse ���
���          � e nos graficos (somente PCOC330)                           ���
�������������������������������������������������������������������������͹��
���Uso       � Consultas de cubos por data e por periodo                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PcocChkTot( aConfig, aView, oView )

Return ( aConfig[7] # 1 .Or. ( aConfig[7] == 1 .And. oView:nAt < Len(oView:aArray) ) )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HideShowGraph �Autor  �Paulo Carnelossi� Data �  22/09/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Exibe ou esconde o painel contendo o grafico nas consultas  ���
���          �do PCO (Qdo esconde mantem apenas a TCBrowse - ListBox)     ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function HideShowGraph(oPanel, oPanelLst, lShowGraph)

If lShowGraph
	//foi utilizado MsgRun para provocar o refresh na listbox
	MsgRun("...",,{|| oPanel:Hide()})
Else
	oPanelLst:Refresh()
	oPanel:Show()
EndIf	
	
lShowGraph := !lShowGraph

Return

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Ana Paula N. Silva     � Data �29/11/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados     ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function MenuDef()
Private aRotina 	:= {	{ STR0002,		"AxPesqui" , 0 , 1},; //"Pesquisar"
							{ "Consultar", 	"Pco330View" , 0 , 2} }  
						
If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	//������������������������������������������������������������������������Ŀ
	//� Adiciona botoes do usuario no Browse                                   �
	//��������������������������������������������������������������������������
	If ExistBlock( "PCOC3301" )
		//P_E������������������������������������������������������������������������Ŀ
		//P_E� Ponto de entrada utilizado para inclusao de funcoes de usuarios no     �
		//P_E� browse da tela de Centros Orcamentarios                                            �
		//P_E� Parametros : Nenhum                                                    �
		//P_E� Retorno    : Array contendo as rotinas a serem adicionados na enchoice �
		//P_E�               Ex. :  User Function PCOC3301                            �
		//P_E�                      Return {{"Titulo", {|| U_Teste() } }}             �
		//P_E��������������������������������������������������������������������������
		If ValType( aUsRotina := ExecBlock( "PCOC3301", .F., .F. ) ) == "A"
			AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
		EndIf
	EndIf      
EndIf	
Return(aRotina)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PcoGrafDay�Autor  � Acacio Egas        � Data �  10/05/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina de cria��o de gafico com o Objeto FwChartFactory    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAPCO P10.R2                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PcoGrafDay(aProcessa,nNivel,cChave,oMain,nTpGrafico,aSeries,lTot,aTots,oLayer,oChart,lCNiv)

Local aLinha := {}
Local nx,ny

Default oLayer 	:= nil
Default oChart 	:= nil
Default lCNiv	:= .F.

oLayer := FWLayer():New()
oLayer:Init(oMain, .T.)
oLayer:addCollumn( 'Col02', 100, .T. )
oLayer:addWindow( 'Col02', 'Win02', "Grafico",100, .F., .T. )

oChart := FWChartFactory():New()
oChart := oChart:getInstance( If(nTpGrafico == 1, LINECHART, BARCOMPCHART ) )
oChart:init( oLayer:getWinPanel( 'Col02', 'Win02' ) )
oChart:SetLegend( CONTROL_ALIGN_RIGHT )
oChart:SetMask( "R$ *@*")
oChart:SetPicture("@E 999,999,999,999.99")

For ny := 1 TO Len(aSeries)
	aAdd( alinha, {nil,{}})
	For nx := 1 to Len(aProcessa)
		If lCNiv // Utilizando quando parametro MV_PCOCNIV = .T.
			alinha[ny,1] := aSeries[ny]
			aAdd( alinha[ny,2],{aProcessa[nx,1],aProcessa[nx,nY+1]})
		Else
			If aProcessa[nx,8] == nNivel .And. (Padr(aProcessa[nx,1],Len(cChave))==cChave)
				alinha[ny,1] := aSeries[ny]
				aAdd( alinha[ny,2],{Substr(aProcessa[nx,1],Len(cChave)+1),aProcessa[nx,2][ny]})
			EndIf
		EndIf
    Next
Next    

If lTot	// Exibe totais das series
	If lCNiv // Utilizando quando parametro MV_PCOCNIV = .T.
		For ny := 1 TO Len(aSeries)
			aAdd( alinha[ny,2],{ "Total" , aTots[ny] } )
		Next	
	Else
		For nx := 1 to Len(aTots)
			For ny := 1 TO Len(aSeries)
				aAdd( alinha[ny,2],{ "Total" , aTots[nx,ny] } )
			Next
		Next
	EndIf
EndIf

For nx := 1 TO Len(aSeries)
	aAdd(aSeries,Nil	)
	oChart:AddSerie(alinha[nx,1], aLinha[nx,2] )
Next
	
oChart:build()
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �pco330Ser �Autor  � Acacio Egas        � Data �  10/05/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida o limite de series da consulta                      ���
���          �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function pco330Ser()

Local lRet	:= .T.

If MV_PAR06>30
	Help("",1,"PCO330SER")
	lRet := .F.
EndIf

Return lRet
