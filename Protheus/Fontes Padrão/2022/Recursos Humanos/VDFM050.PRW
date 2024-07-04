#include "VDFM050.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWMVCDEF.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VDFM050  ³ Autor ³ TOTVS.                     ³ Data ³ 01/07/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ relatório via e-mail com posicionamento da data de cada membro,	 ³±±
±±³listando quem ainda esta em estágio probatório 								 ³±±
±±³          ³                                                                   ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               ³±±±±±±±±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄ¿±±
±±³Programador   ³ Data   ³ PRJ/REQ-Chamado ³  Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcos Pereira³11/03/14³xxx. xxxxxxx     ³ Ajuste para desativar oModel corretamente  ³±±
±±³              ³        ³REQ. xxxxxx      ³     									     ³±±
±±³              ³        ³                 ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} VDFM050
relatório via e-mail com posicionamento da data de cada membro,
listando quem ainda esta em estágio probatório 
e sua respectiva data para vitaliciamento.
@author Everson S.P Junior
@since 05/07/13
@version P11
@return nil
/*/
//------------------------------------------------------------------------------------ 
Function VDFM050(aParam)
Local   oModel
Local   aAreaSRA    := {}
Local	aArea		:= {}
Local	clAccount	:= ''
Local	clPassword	:= ''
Local	clServer	:= ''
Local	clFrom		:= ''
Local	clDest		:= '' 
Local	lMsg        := .T.
Local   lGrv,lCont  := .F.
Local	cLog		:= ""
Local	clAssunto	:= STR0001//'Aviso de Prazos para Vitaliciamento'
Local	clMensagem	:= ""
Local   nX,nY,nI    := 0
Local   aQueySRA    := {}
Local   aQueyRCC    := {}
Local   aFuncEML    := {}
Local   aFunEnvio   := {}
		
If !(Type("oMainWnd")=="O") // é Rotina Auto...
	RpcSetType(3)
	RpcSetEnv(aParam[1],aParam[2],,,"VDF")
EndIf
aAreaSRA    := SRA->( GetArea() )
aArea		:= GetArea()
clDest		:= GetMV( "MV_VDFVIT2" )

aQueySRA:= FUNCEML(.T.)//Retorna Array com todos os funcionarios em Estágio Probatório e Vitaliciamento
aQueyRCC:= FUNCEML(.F.)//Retorna Array com informações e regras de dias para o envio do e-mail.

If !Empty(aQueySRA) //Inicia o Obj da tela de consulta de Estágio Probatório e Vitaliciamento para recuperar as informações! 
	For nX :=1 To Len(aQueySRA) 
		dbSelectArea( 'SRA' )
		dbSetOrder( 1 ) //
		SRA->( dbSeek( FwxFilial( "SRA" ) + aQueySRA[nX][1] ) ) 
		
		oModel := FWLoadModel( 'VDFC010' )
		oModel:SetOperation( MODEL_OPERATION_UPDATE )
		oModel:Activate()
		aAdd(aFuncEML,{aQueySRA[nX][1],aQueySRA[nX][2],oModel:GetValue( 'SRAMASTER', 'RA_NOME' ),oModel:GetValue( 'SRAMASTER', 'RA_DTNOMEA' ),oModel:GetValue( 'SRAMASTER', 'RA_TEMVITA' ),;
		(oModel:GetValue( 'SRAMASTER', 'RA_DATVITA' )-dDataBase),aQueySRA[nX][2],aQueySRA[nX][3]})
		oModel:DeActivate()
	Next	
EndIf
aSort(aQueyRCC,,,{|x,y|x[1] > y[1]})
For nX :=1 To Len(aFuncEML)// criação do Array de acordo com as regras de envio.
	For nY :=1 To Len(aQueyRCC)-1	
		//Bloco para a primeira vez da regra  campo de controle de e-mail estiver zerado
		If (aFuncEML[nX][6] <= aQueyRCC[nY][1]  .AND. aFuncEML[nX][6] > aQueyRCC[nY+1][1]) .AND. Empty(aFuncEML[nX][8])
			aAdd(aFunEnvio,{aFuncEML[nX][1],aFuncEML[nX][2],aFuncEML[nX][3],aFuncEML[nX][4],aFuncEML[nX][5],aFuncEML[nX][7],aQueyRCC[nY][2],aQueyRCC[nY][1]})
			If aQueyRCC[nY][1] < aQueyRCC[1][1]
				For nI :=1 To nY -1
					aAdd(aFunEnvio,{aFuncEML[nX][1],aFuncEML[nX][2],aFuncEML[nX][3],aFuncEML[nX][4],aFuncEML[nX][5],aFuncEML[nX][7],aQueyRCC[nI][2],aQueyRCC[nY][1]})
				Next
			EndIf	 		
		//Bloco para o Intermedio da Regra entre o Primeiro e o Ultimo Valor da regra!
		ElseIf(aFuncEML[nX][6] <= aQueyRCC[nY][1] .AND. aFuncEML[nX][6] > aQueyRCC[nY+1][1]) .AND. !Empty(aFuncEML[nX][8]) .AND. ( aQueyRCC[nY][1] <> aFuncEML[nX][8])
			aAdd(aFunEnvio,{aFuncEML[nX][1],aFuncEML[nX][2],aFuncEML[nX][3],aFuncEML[nX][4],aFuncEML[nX][5],aFuncEML[nX][7],aQueyRCC[nY][2],aQueyRCC[nY][1]})
			For nI :=1 To Len(aQueyRCC)
				If aQueyRCC[nI][1] == aFuncEML[nX][8]
					lCont := .T.
					Exit
				Else
					lCont := .F.	 	
				EndIf 
			Next  
			If lCont
				If aQueyRCC[nY][1] < aQueyRCC[nI][1] .AND.!Empty(nI) 
					For nI:=nI+1  To nY -1
						aAdd(aFunEnvio,{aFuncEML[nX][1],aFuncEML[nX][2],aFuncEML[nX][3],aFuncEML[nX][4],aFuncEML[nX][5],aFuncEML[nX][7],aQueyRCC[nI][2],aQueyRCC[nY][1]})
					Next
				EndIf
			EndIf		 
		//Bloco para Ultimo valor da Regra (30 dias)
		ElseIf(aFuncEML[nX][6] <= aQueyRCC[Len(aQueyRCC)][1] .AND. aQueyRCC[Len(aQueyRCC)][1] <> aFuncEML[nX][8])
			aAdd(aFunEnvio,{aFuncEML[nX][1],aFuncEML[nX][2],aFuncEML[nX][3],aFuncEML[nX][4],aFuncEML[nX][5],aFuncEML[nX][7],aQueyRCC[Len(aQueyRCC)][2],aQueyRCC[Len(aQueyRCC)][1]})
			For nI :=1 To Len(aQueyRCC)
				If aQueyRCC[nI][1] == aFuncEML[nX][8]
					lCont := .T.
					Exit
				ElseIf Empty(aFuncEML[nX][8])
					lCont := .T.
					nI    := 0
					Exit
				Else
					lCont := .F.
				EndIf 
			Next  
			If lCont
				For nI:=nI+1  To Len(aQueyRCC) -1
					aAdd(aFunEnvio,{aFuncEML[nX][1],aFuncEML[nX][2],aFuncEML[nX][3],aFuncEML[nX][4],aFuncEML[nX][5],aFuncEML[nX][7],aQueyRCC[nI][2],aQueyRCC[Len(aQueyRCC)][1]})
				Next
			EndIf
			Exit
		EndIf
	
	Next
Next

//Função para gerar o corpo do email em html de acordo com o layout do cliente FSGerHtml
clMensagem := FSGerHtml(aFunEnvio)				
If !Empty(clDest) .And. !Empty(clMensagem)
//se nao possuir 2 endereços, coloca o ";" para que a função padrão de envio de email funcione.
	If At(";",clDest) == 0
		clDest := AllTrim(clDest) + ";"
	EndIf
	//Envia email para a área de cobrança da empresa.*/
	lGrv := gpeMail(clAssunto,clMensagem,clDest,{},@cLog)
EndIf

If lGrv
	Begin Transaction
		For nX:= 1 To Len(aFunEnvio)
			If SRA->( dbSeek( FwxFilial( "SRA" ) + aFunEnvio[nX][1] ) )
				RecLock("SRA",.F.)
				SRA->RA_CTRLEMA := aFunEnvio[nX][8]
				SRA->(MsUnlock())
			End	
		Next
	End Transaction	
EndIf

TRBSRA->(dbCloseArea())
TRBRCC->(dbCloseArea())
RestArea( aAreaSRA )
RestArea( aArea )
If !(Type("oMainWnd")=="O")
	RpcClearEnv()
EndIf	
Return

//---------------------------------------------------------------
/*/{Protheus.doc} FSGerHtml
aviso para que os responsáveis confeccionem os relatórios da corregedoria
@author Everson S.P Junior
@since 05/07/13
@version P11 
@return cHtml - Corpo do email formatado no layout html do cliente
/*/ 
//-----------------------------------------------------------------
Static Function FSGerHtml(aFunEnvio)
Local nX      := 0	
Local cHtml   := ""
Local lJunta  := .F.
LOcal cMsgRoda:= GetMV("MV_VDFVIT3")

aSort(aFunEnvio,,,{|x,y|x[01] > y[01]})

For nX := 1 to Len(aFunEnvio)
	cHtml	+= '<html>'
	cHtml	+= ''
	cHtml	+= '<head>'
	cHtml	+= '<meta http-equiv=Content-Type content="text/html; charset=windows-1252">'
	cHtml	+= '<meta name=Generator content="Microsoft Word 12 (filtered)">'
	cHtml	+= '<style>'
	cHtml	+= '<!--'
	cHtml	+= '/* Font Definitions */'
	cHtml	+= '@font-face'
	cHtml	+= '{font-family:"Cambria Math";'
	cHtml	+= 'panose-1:2 4 5 3 5 4 6 3 2 4;}'
	cHtml	+= '@font-face'
	cHtml	+= '{font-family:Calibri;'
	cHtml	+= 'panose-1:2 15 5 2 2 2 4 3 2 4;}'
	cHtml	+= '/* Style Definitions */'
	cHtml	+= 'p.MsoNormal, li.MsoNormal, div.MsoNormal'
	cHtml	+= '{mso-style-name:"Normal\,TOTVS Texto";'
	cHtml	+= 'margin:0cm;'
	cHtml	+= 'margin-bottom:.0001pt;'
	cHtml	+= 'text-align:justify;'
	cHtml	+= 'text-indent:1.0cm;'
	cHtml	+= 'line-height:115%;'
	cHtml	+= 'font-size:9.0pt;'
	cHtml	+= 'font-family:"Calibri","sans-serif";}'
	cHtml	+= '.MsoPapDefault'
	cHtml	+= '{margin-bottom:10.0pt;'
	cHtml	+= 'line-height:115%;}'
	cHtml	+= '@page WordSection1'
	cHtml	+= '{size:595.3pt 841.9pt;'
	cHtml	+= 'margin:70.85pt 3.0cm 70.85pt 3.0cm;}'
	cHtml	+= 'div.WordSection1'
	cHtml	+= '{page:WordSection1;}'
	cHtml	+= '-->'
	cHtml	+= '</style>'
	cHtml	+= ''
	cHtml	+= '</head>'
	cHtml	+= ''
	cHtml	+= '<body lang=PT-BR>'
	cHtml	+= ''
	cHtml	+= '<div class=WordSection1>'
	cHtml	+= ''
	cHtml	+= '<p class=MsoNormal style="margin-left:4.0pt;text-indent:0cm"><b><span'
	cHtml	+= 'style="font-size:12.0pt;line-height:115%;font-family:"Times New Roman","serif"">Promotor '
	cHtml	+= 'Substituto:     </span></b><span style="font-size:12.0pt;line-height:115%;'
	cHtml	+= 'font-family:"Times New Roman","serif"">'+aFunEnvio[nX][3]+'</span></p>'
	cHtml	+= ''
	cHtml	+= '<p class=MsoNormal style="text-indent:0cm">&nbsp;</p>'
	cHtml	+= '<table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 align=left'
	cHtml	+= 'width=605 style="width:16.0cm;border:outset black 1.0pt;margin-left:4.8pt;'
	cHtml	+= 'margin-right:4.8pt">'
	cHtml	+= '<tr style="height:12.6pt">'
	cHtml	+= '<td width=172 valign=top style="width:129.1pt;border:inset black 1.0pt;'
	cHtml	+= 'padding:5.25pt 5.25pt 5.25pt 5.25pt;height:12.6pt">'
	cHtml	+= '<p class=MsoNormal align=left style="margin-bottom:5.95pt;text-align:left;'
	cHtml	+= 'text-indent:0cm;line-height:normal"><b>Relatório</b></p>'
	cHtml	+= '</td>'
	cHtml	+= '<td width=433 valign=top style="width:324.5pt;border:inset black 1.0pt;'
	cHtml	+= 'padding:5.25pt 5.25pt 5.25pt 5.25pt;height:12.6pt">'
	cHtml	+= '<p class=MsoNormal align=left style="margin-bottom:5.95pt;text-align:left;'
	cHtml	+= 'text-indent:0cm;line-height:normal"><span Arial?,?sans-serif?;color:black?="">'
	cHtml	+= '<b>'+aFunEnvio[nX][7]+'</b>'
	cHtml	+= '.</span></p>'
	cHtml	+= '</td>'
	cHtml	+= '</tr>'
	cHtml	+= '<tr>'
	cHtml	+= '<td width=172 valign=top style="width:129.1pt;border:inset black 1.0pt;'
	cHtml	+= 'padding:5.25pt 5.25pt 5.25pt 5.25pt">'
	cHtml	+= '<p class=MsoNormal align=left style="margin-bottom:5.95pt;text-align:left;'
	cHtml	+= 'text-indent:0cm;line-height:normal"><b>Matrícula</b></p>'
	cHtml	+= '</td>'
	cHtml	+= '<td width=433 valign=top style="width:324.5pt;border:inset black 1.0pt;'
	cHtml	+= 'padding:5.25pt 5.25pt 5.25pt 5.25pt">'
	cHtml	+= '<p class=MsoNormal align=left style="margin-bottom:5.95pt;text-align:left;'
	cHtml	+= 'text-indent:0cm;line-height:normal"><span Arial?,?sans-serif?;color:black?="">'+aFunEnvio[nX][1]+'</span></p>'
	cHtml	+= '</td>'
	cHtml	+= '</tr>'
	cHtml	+= '<tr>'
	cHtml	+= '<td width=172 valign=top style="width:129.1pt;border:inset black 1.0pt;'
	cHtml	+= 'padding:5.25pt 5.25pt 5.25pt 5.25pt">'
	cHtml	+= '<p class=MsoNormal align=left style="margin-bottom:5.95pt;text-align:left;'
	cHtml	+= 'text-indent:0cm;line-height:normal"><b>Data de Nomeação</b></p>'
	cHtml	+= '</td>'
	cHtml	+= '<td width=433 valign=top style="width:324.5pt;border:inset black 1.0pt;'
	cHtml	+= 'padding:5.25pt 5.25pt 5.25pt 5.25pt">'
	cHtml	+= '<p class=MsoNormal align=left style="margin-bottom:5.95pt;text-align:left;'
	cHtml	+= 'text-indent:0cm;line-height:normal"><span Arial?,?sans-serif?;color:black?="">'+dToc(aFunEnvio[nX][4])+'</span></p>'
	cHtml	+= '</td>'
	cHtml	+= '</tr>'
	cHtml	+= '<tr style="height:1.0pt">'
	cHtml	+= '<td width=172 valign=top style="width:129.1pt;border:inset black 1.0pt;'
	cHtml	+= 'padding:5.25pt 5.25pt 5.25pt 5.25pt;height:1.0pt">'
	cHtml	+= '<p class=MsoNormal align=left style="margin-bottom:5.95pt;text-align:left;'
	cHtml	+= 'text-indent:0cm;line-height:normal"><b>Tempo para Vitaliciamento</b></p>'
	cHtml	+= '</td>'
	cHtml	+= '<td width=433 valign=top style="width:324.5pt;border:inset black 1.0pt;'
	cHtml	+= 'padding:5.25pt 5.25pt 5.25pt 5.25pt;height:1.0pt">'
	cHtml	+= '<p class=MsoNormal align=left style="margin-bottom:5.95pt;text-align:left;'
	cHtml	+= 'text-indent:0cm;line-height:normal"><span Arial?,?sans-serif?;color:black?="">'+aFunEnvio[nX][5]+'</span></p>'
	cHtml	+= '</td>'
	cHtml	+= '</tr>'
	cHtml	+= '</table>'
	cHtml	+= '<br>'
    lJunta  := .T. 
		
Next
If lJunta 
	cHtml	+= '<p class=MsoNormal style="margin-left:4.0pt;text-indent:0cm"><b><span style="font-size:12.0pt;line-height:115%;'
	cHtml	+= 'font-family:"Times New Roman","serif"">'+cMsgRoda+'</span></p>'
	cHtml	+= '</div>'
	cHtml	+= '<br>'
	cHtml	+= '<br>'
	cHtml	+= '</body>'
	cHtml	+= ''
	cHtml	+= '</html>'
EndIf

Return cHtml


//---------------------------------------------------------------
/*/{Protheus.doc} FUNCEML
FUNCEML(.T.)//Retorna Array com todos os funcionarios em Estágio Probatório e Vitaliciamento
FUNCEML(.F.)//Retorna Array com informações e regras de dias para o envio do e-mail.
@author Everson S.P Junior
@since 05/07/13
@version P11 
@return aRet
/*/ 
//-----------------------------------------------------------------

Static Function FUNCEML(lTipo)
Local cQryTmp := ' '
Local aRet    := {}

If lTipo
	cQryTmp += " Select RA_MAT,RA_DTNOMEA,RA_NOME,RA_CHAPA,RA_CTRLEMA "+ CRLF 
	cQryTmp += "FROM " 	+ RetSqlName("SRA") + " SRA, " + CRLF
	cQryTmp += " WHERE  " + CRLF
	cQryTmp += " SRA.RA_FILIAL  ='"+FwxFilial('SRA')+"' AND "+ CRLF
	cQryTmp += " SRA.RA_CATFUNC ='0' AND "+ CRLF
    cQryTmp += " SRA.RA_DEFETIV =' ' AND "+ CRLF
	cQryTmp += " SRA.D_E_L_E_T_ =' ' "+ CRLF
	cQryTmp := ChangeQuery(cQryTmp)
	dbUseArea(.T., 'TOPCONN', TcGenQry(,, cQryTmp), 'TRBSRA', .F., .T. )
	
	While !TRBSRA->(Eof())
		aAdd(aRet,{TRBSRA->RA_MAT,TRBSRA->RA_CHAPA,TRBSRA->RA_CTRLEMA})
	 	TRBSRA->(DbSkip())
	EndDo
Else
	cQryTmp += " SELECT RCC_CONTEU "+ CRLF 
	cQryTmp += " FROM  " 	+ RetSqlName("RCC") + " RCC, " + CRLF
	cQryTmp += " WHERE " + CRLF
	cQryTmp += " RCC.RCC_FILIAL  ='"+FwxFilial('RCC')+"' AND "+ CRLF
	cQryTmp += " RCC.RCC_CODIGO ='S104' AND "+ CRLF
	cQryTmp += " RCC.D_E_L_E_T_ =' ' "+ CRLF
	cQryTmp := ChangeQuery(cQryTmp)
	dbUseArea(.T., 'TOPCONN', TcGenQry(,, cQryTmp), 'TRBRCC', .F., .T. )
	
	While !TRBRCC->(Eof())
		aAdd(aRet,{Val(SUBSTR(TRBRCC->RCC_CONTEU,0001,0003)),SUBSTR(TRBRCC->RCC_CONTEU,0004,0100)}) 
	 	TRBRCC->(DbSkip())
	EndDo	
EndIf

Return aRet
