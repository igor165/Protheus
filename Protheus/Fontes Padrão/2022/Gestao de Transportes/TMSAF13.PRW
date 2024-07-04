#include "PROTHEUS.ch"
#include "TMSAF13.CH"
#Include "FWMVCDEF.CH"

/*/----------------------------------------------------------------
{Protheus.doc} TMSAF13Mnt()
Monta a Tela com os Roteiros que devem ter uma nova rota cadastrada

Uso: TMSAF12

@sample
//TMSAF13Mnt

Estrutura aRray aRoteiros:
	[nx,1] == 'Status do Roteiro (1=Roteiro Cadastrado;2=Sugestao de Rota;3=Nao Encontrado;4-Roteiro Identico)'
	[nx,2] == 'Rota'
	[nx,3] == 'Roteiro'
	[nx,4] == 'Cliente Devedor'
	[nx,5] == 'Loja do Devedor'
	[nx,6] == 'Numero do Contrato'
	[nx,7] == 'Total KM do Roteiro'
	[nx,8] == 'Municipio Origem'
	[nx,9] == 'Municipio Destino'
	[nx,10] == 'Região de Origem'
	[nx,11] == 'Região de Destino'
	[nx,12]== 'Servico de Transporte'
	[nx,13]== 'Obj. Modelo do Roteiro'
	[nx,14]== 'Vetor para apresentação da tela de sugestão e rotas'
@author Leandro Paulino
@since 13/05/2016
@version 1.0
------------------------------------------------------------------/*/
Function TMSAF13Mnt(aRoteiros,aNewRot,oModel)

Local aAreaBKP	:= GetArea()	// Recebe a Area Ativa
Local oDlg			:= Nil  		// Recebe o objeto da Dialog				
Local oNewRota	:= LoadBitmap( GetResources(), "BR_VERMELHO" )      // Legends : CHECKED  / LBOK  /LBTIK
Local oSugRota	:= LoadBitmap( GetResources(), "BR_AMARELO" )      // Legends : CHECKED  / LBOK  /LBTIK
Local oOK			:= LoadBitmap( GetResources(), "BR_VERDE" )    // Legends : UNCHECKED /LBNO
Local oIdentRot	:= LoadBitmap( GetResources(), "BR_AZUL" )    // Legends : UNCHECKED /LBNO
Local cRota		:= ''  
LOcal lGrava		:= .F.
Local aButtons    := {}

Default aRoteiros := {}				// Recebe os Agendamentos
Default aNewRot   := {}
Default oModel    := FwModelActive()

If Len(aRoteiros) > 0

	 Define MSDialog oDlg TITLE STR0001 FROM c( 180 ), c( 180 ) TO c( 530 ), c( 910 ) PIXEL //"Cadastrar Rotas para os Roteiros"
	 // Chamadas das Listbox do Sistema
	 
	 @ c( 025 ), c( 005 ) ListBox oListBox Fields ;
	 Header "",STR0002,STR0023,STR0003,STR0004,STR0005,STR0006; //"Roteiro"###"Rota Orig."###"Pasta"###"Origem"###"Destino"###"KM"
	 Size c( 360 ), c( 150 ), c ( 150 ), c ( 150) Of oDlg Pixel 
	 
	 oListBox:SetArray( aRoteiros )
	 
	  oListBox:bLine := {|| { 		Iif(aRoteiros[oListBox:nAt][1] == '4', oIdentRot, Iif(aRoteiros[oListBox:nAt][1] == '1',oOK,IIF(aRoteiros[oListBox:nAt][1] == '2'  .OR. Len(aNewRot) > 0,oSugRota,oNewRota)) ),;
	 									aRoteiros[oListBox:nAt][3]	,;
	 									aRoteiros[oListBox:nAt][2]	,;
	 									Iif(aRoteiros[oListBox:nAt][4] == "SEMDEV",STR0024,IIF(Empty(cTitFolder:= Posicione('SA1',1,FwxFilial("SA1")+aRoteiros[oListBox:nAt][4]+aRoteiros[oListBox:nAt][5],"A1_NREDUZ")),STR0009,cTitFolder))	,;
										aRoteiros[oListBox:nAt][8]	,;
										aRoteiros[oListBox:nAt][9]	,;
										aRoteiros[oListBox:nAt][7]	,}} //"GERAL"
										
	 oListBox:BLDBLCLICK := { |oObj,nCol|	If(nCol==1,AF13LegNRot(),(IIf(aRoteiros[oListBox:nAt][1]=='3'.AND. Len(aNewRot) == 0 ,lGrava := !Empty(TF13GrRota(@cRota,aRoteiros[oListBox:nAt][12],aNewRot,oModel)),;
	 											IIf(aRoteiros[oListBox:nAt][1] $ "1|2|4"  .OR. Len(aNewRot) > 0 ,lGrava := TmsF13SugR(aRoteiros[oListBox:nAt][14],@cRota,aRoteiros[oListBox:nAt][12],aNewRot,oModel),)),;
	 											IIf(lGrava,aRoteiros[oListBox:nAt][2]:= @cRota,Nil), IIf(lGrava,aRoteiros:= aClone(AF13AtuRot(aRoteiros,aRoteiros[oListBox:nAt])),Nil),cRota := "",oListBox:Refresh()))}
	
	 oListBox:bHeaderClick:= {|oObj,nCol| If(nCol==1,AF13LegNRot(),)}
	 		
	 // Cria componentes padroes do sistema
	 AAdd(aButtons,{STR0007,{ ||	IIf(aRoteiros[oListBox:nAt][1]=='3' .AND. Len(aNewRot) == 0,lGrava := !Empty(TF13GrRota(@cRota,aRoteiros[oListBox:nAt][12],aNewRot,oModel)),;
	 										IIf(aRoteiros[oListBox:nAt][1] $ "1|2|4" .OR. Len(aNewRot) > 0 ,lGrava := TmsF13SugR(aRoteiros[oListBox:nAt][14],@cRota,aRoteiros[oListBox:nAt][12],aNewRot,oModel),)),;
	 										IIf(lGrava,aRoteiros[oListBox:nAt][2]:= @cRota,Nil), IIf(lGrava,aRoteiros:= aClone(AF13AtuRot(aRoteiros,aRoteiros[oListBox:nAt])),Nil),cRota := "",oListBox:Refresh()} , STR0007,STR0007  }) //'Cadastrar'
	 
	 AAdd(aButtons,{STR0008 ,{ ||AF13LegNRot()} , STR0008 , STR0008  })//"Legenda"
	  
	 Activate MSDialog oDlg ON INIT EnchoiceBar(oDlg,,{|| oDlg:End() },, aButtons,,,,,,.F. )
EndIf

RestArea(aAreaBKP)

Return aRoteiros 


/*/-----------------------------------------------------------
{Protheus.doc} AF13LegNRot
Legenda de novas ROtas

Uso: TMSAF13

@sample
//AF13LegNRot()

@author Paulo Henrique Corrêa Cardoso
@since 10/06/2016
@version 1.0
-----------------------------------------------------------/*/
Static Function AF13LegNRot()
Local aArea			:= GetArea()
Local aLegenda		:= {}		
Local cTitulo			:= ''

Aadd(aLegenda,{"BR_VERMELHO", STR0010}) //"Sem Sugestão de Rotas"
Aadd(aLegenda,{"BR_AMARELO" , STR0011}) //"Encontrado roteiro com mesma origem e destino"
Aadd(aLegenda,{"BR_VERDE" 	, STR0012}) //"Rota Cadastrada"
Aadd(aLegenda,{"BR_AZUL" 	, STR0013}) //"Encontrado Roteiro Idêntico"


cTitulo:= STR0008 //"Legenda"

If Len(aLegenda) > 0  
	BrwLegenda(cTitulo, STR0008 , aLegenda) //"Legenda"
EndIf

RestArea(aArea)

Return


/*/-----------------------------------------------------------
{Protheus.doc} AF13AtuRot
Atualiza os itens do array após o vínculo das rotas nos roteiros

Uso: TMSAF13

@sample
// AF13AtuRot()

@author Leandro Paulino 
@since 20/06/2016
@version 1.0
-----------------------------------------------------------/*/
Static Function  AF13AtuRot(aRotTotal,aRotAtu)

Local nPosRot	:= 0

Default aRotTotal	:= {}
Default aRotAtu	:= {}

ASort( aRotTotal,,,{|x,y| x[3] < y[3] } )
nPosRot := Ascan( aRotTotal,{|x| x[3]== aRotAtu[3] })
While nPosRot <= Len(aRotTotal) .And. (aRotTotal[nPosRot,3]) == aRotAtu[3]  
	aRotTotal[nPosRot][1] := '1'
	aRotTotal[nPosRot][2] := ArotAtu[2]		
	nPosRot++			
EndDo
	
Return aRotTotal

/*/-----------------------------------------------------------
{Protheus.doc} F13RotIdnt
Busca roteiro identico na DDJ

Uso: TMSF13

@sample
//F13RotIdnt(aRotCli,cSerTms,aRotaRotei) 

@author Leandro Paulino
@since 11/04/2016
@version 1.0
-----------------------------------------------------------/*/

Function F13RotIdnt(aRotCli,cSerTms,aRotaRotei,aPontMDFe) 
Local cQuery     := ''             // Recebe a Query
Local cAliasNew  := GetNextAlias() // Recebe o proximo alias disponivel
Local lRoteir    := .F.            // Recebe se existe roteiro exatamente igual em uma rota
Local cQueryCpl  := ""             // Recebe o conteudo da clausula IN de Pontos de Passagem
Local nCount     := 0              // Recebe o contador 
Local nTamRotCli := 0              // Recebe o tamanho do array de clientes
Local aRotas     := {}             // Recebe as Rotas
Local aRotei     := {}             // Recebe os Roteiros
Local cInRegRot  := ""				// Recebe o conteudo da clausula IN de Roteiros
Local cPontMDFe  := ""             // Recebe o conteudo da clausula IN dos pontos do MDF-e  
Local lDIQEmpty  := .F.            //
           
Default aRotCli    := {}           // Recebe o array de clientes 
Default cSerTms    := ""           // Recebe o serviço de transporte 
Default aRotaRotei := {}           // Recebe as rotas e roteiros - sera o retorno, array de referencia
Default aPontMDFe  := {}           // Recebe os pontos do MDF-e do roteiro geral

// Monta a Clausula IN
If (nTamRotCli := Len(aRotCli)) > 0
	
	For nCount := 1 To nTamRotCli
		cQueryCpl += RTrim(Iif(Empty(cQueryCpl),"",",") + aRotCli[nCount,1] + aRotCli[nCount,2] + aRotCli[nCount,3] + aRotCli[nCount,6])
	Next nCount
		
	
EndIf	

If !Empty(cQueryCpl)
	cQuery := " SELECT  DDJ.DDJ_ROTEIR " 
	cQuery += " FROM " + RetSqlName("DDJ") + " DDJ "
	cQuery += " INNER JOIN (SELECT 	MAX(DDJ_SEQUEN)Maximo,  "
	cQuery += " 						DDJ_ROTEIR "
	cQuery += " 				FROM " + RetSqlName("DDJ")
	cQuery += " 				WHERE D_E_L_E_T_ = ' ' "
	cQuery += " 		 			   AND DDJ_FILIAL 	= '" + xFilial("DDJ") + "' "
	cQuery += " 				GROUP BY DDJ_ROTEIR "
	cQuery += "  				)TAB1 "
	cQuery += "  	ON TAB1.DDJ_ROTEIR = DDJ.DDJ_ROTEIR  "				
					
	cQuery += " WHERE 	DDJ.DDJ_FILIAL 		= '" + xFilial("DDJ") + "' "
	cQuery += " AND 		DDJ.DDJ_SEQUEN || DDJ.DDJ_CLIENT || DDJ.DDJ_LOJA || DDJ.DDJ_SEQEND IN  "
	
	cQuery +=  FormatIn( cQueryCpl , "," ) 
	
	cQuery += " AND TAB1.Maximo = '" + StrZero(Len(aRotCli),TamSX3('DDJ_SEQUEN')[1] ) + "' "
	cQuery += " AND 		DDJ.D_E_L_E_T_ = ' ' "
	
	cQuery += " GROUP BY DDJ.DDJ_ROTEIR "
	cQuery += " HAVING COUNT(1) = " + cValToChar(Len(aRotCli)) 
	cQuery += " ORDER BY DDJ.DDJ_ROTEIR"
	
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasNew,.F.,.T.)
	
	
	//Query de Rota Exatamente Igual	
	While (cAliasNew)->(!Eof())
		lRoteir    := .T.
		
		AADD(aRotei,(cAliasNew)->DDJ_ROTEIR)
		(cAliasNew)->(DbSkip())	 
	EndDo

	(cAliasNew)->(dbCloseArea())
	
	// Busca Rotas por MDF-e
	If Len(aPontMDFe) > 1 	
		aRotas := F13BusRota(aClone(aRotei),cSerTms, aClone(aPontMDFe), .F.)		

		// Não encontrou rotas 
		If Empty(aRotas) 
			lDIQEmpty := .T.
		EndIf
		
	EndIf
	
	// Busca Rotas sem MDF-e ou caso o mesmo não seja encontrado
	If Len(aPontMDFe) <= 1 .OR. lDIQEmpty
		aRotas := F13BusRota(aClone(aRotei),cSerTms, aClone(aPontMDFe), lDIQEmpty)	
	EndIf
	
	 AADD(aRotaRotei,aRotei)
	 AADD(aRotaRotei,aRotas)
	 
EndIf
	
Return  lRoteir

/*/-----------------------------------------------------------
{Protheus.doc} F13RotSem
Busca roteiro identico na DDJ

Uso: TMSF13

@sample
//F13RotSem(aRotCli,cSerTms,aRotaRotei,lRoteiro) 

@author Kaiam
@since 08/04/2016
@version 1.0
-----------------------------------------------------------/*/
Function F13RotSem(aRotCli,cSerTms,aRotaRotei,lRoteiro,aPontMDFe)
Local cQuery       := ""             // Recebe a Query
Local cAliasBsc2   := GetNextAlias() // Recebe o Alias da tabela Temporaria
Local aVet         := {}             // Recebe o vetor de retono de Rotas
Local nCount       := 0              // Recebe o contador
Local cMunOri      := ""             // Recebe o Municipio de origem
Local cEstOri      := ""             // Recebe o estado de origem
Local cMunDes      := ""             // Recebe o Municipio de destino
Local cEstDes      := ""             // Recebe o estado de destino
Local nQtdTrecho   := 0              // Recebe a quantidade de trechos
Local cPontMDFe    := ""             // Recebe o conteudo da clausula IN dos pontos do MDF-e 
Local lAchMdfe     := .F.            // Recebe se encontrou rotas baseadas em MDF-e
Default aRotCli    := ""             // Recebe o Roteiro do Cliente
Default cSerTms    := ""             // Recebe o serviço de transporte
Default aRotaRotei := {}             // Recebe as rotas e os roteiros identicos
Default lRoteiro   := .F.            // Recebe true caso tenha roteiros identicos
Default aPontMDFe  := {}             // Recebe os pontos do MDF-e do roteiro geral

// Caso exista roteiros exatamente iguais adiciona eles ao retorno
If lRoteiro .AND. Len(aRotaRotei) > 0
	For nCount := 1 To Len(aRotaRotei)
		AADD(aVet, {aRotaRotei[nCount][1],aRotaRotei[nCount][2]} )
	Next nCount
EndIf

If Len(aPontMDFe) > 1
	
	For nCount := 1 To Len(aPontMDFe)
		cPontMDFe += Iif(Empty(cPontMDFe),"",",") +  STRZERO( nCount , TamSx3('DIQ_SEQUEN')[1]) + aPontMDFe[nCount]
	Next nCount
	
	cAliasbsc2  := GetNextAlias()
	cQuery := " SELECT  DJH.DJH_ROTA, DJH_ROTEIR " 
	cQuery += " FROM " + RetSqlName("DJH") + " DJH "
	cQuery += " INNER JOIN  " 	+ RetSqlName("DA8") + " DA8 "
	cQuery += " ON 		DA8.DA8_FILIAL 	= '" + Fwxfilial("DA8") + "' " 	 
	cQuery += " AND 		DA8.DA8_COD  		= DJH.DJH_ROTA "  
	cQuery += " AND 		DA8.DA8_ATIVO		= '1' "
	cQuery += " AND 		DA8.DA8_SERTMS 	= '" + cSerTms + 	"'"
	cQuery += " AND 		DA8.D_E_L_E_T_	= ' ' "
	
	cQuery += " INNER JOIN  " 	+ RetSqlName("DIQ") + " DIQ "
	cQuery += " ON 		DIQ.DIQ_FILIAL 	= '" + Fwxfilial("DIQ") + "' " 	 
	cQuery += " AND 		DIQ.DIQ_ROTA 		= DJH.DJH_ROTA "  
	cQuery += " AND 		DIQ.DIQ_ROTEIR 		= DJH.DJH_ROTEIR "  
	cQuery += " AND 		DIQ.D_E_L_E_T_	= ' ' "
	
	If Len(aPontMDFe) > 1
		cQuery += " INNER JOIN (SELECT 	MAX(DIQ_SEQUEN)Maximo,  "
		cQuery += " 						DIQ_ROTA ,DIQ_ROTEIR "
		cQuery += " 				FROM " + RetSqlName("DIQ")
		cQuery += " 				WHERE D_E_L_E_T_ = ' ' "
		cQuery += " 		 			   AND DIQ_FILIAL 	= '" + xFilial("DIQ") + "' "
		cQuery += " 		 			   AND DIQ_ROTEIR   <> '"+Space(TamSx3('DIQ_ROTEIR')[1])+ "' "
		cQuery += " 				GROUP BY DIQ_ROTA ,DIQ_ROTEIR "
		cQuery += "  				)TAB1 "
		cQuery += "  	ON TAB1.DIQ_ROTA = DJH.DJH_ROTA  "
	EndIf
					
	cQuery += " WHERE 	DJH.DJH_FILIAL 		= '" + xFilial("DJH") + "' "
	
	If Len(aPontMDFe) > 1
		cQuery += " AND 		DIQ.DIQ_SEQUEN || DIQ.DIQ_EST IN  "
		cQuery +=  FormatIn( cPontMDFe , "," )  
		cQuery += " AND TAB1.Maximo = '" + StrZero(Len(aPontMDFe),TamSX3('DIQ_SEQUEN')[1] ) + "' "
	EndIf
		
	cQuery += " GROUP BY DJH.DJH_ROTA, DJH_ROTEIR "
	
	If Len(aPontMDFe) > 1
		cQuery += " HAVING COUNT(1) = " + cValToChar(Len(aPontMDFe))
	EndIf
	
	cQuery += " ORDER BY DJH.DJH_ROTA, DJH_ROTEIR"
	
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasbsc2,.F.,.T.)
	
	
	//Query de Rota Exatamente Igual	
	While (cAliasbsc2)->(!Eof())
		If aScan( aVet , { |x| Alltrim(x[1]) == Alltrim((cAliasbsc2)->DJH_ROTA)}) == 0
			aAdd(aVet, {(cAliasbsc2)->DJH_ROTA,""})
			lAchMdfe := .T.
		EndIf
		(cAliasbsc2)->(DbSkip())	 
	EndDo

	(cAliasbsc2)->(dbCloseArea())

EndIf

If Len(aPontMDFe) <= 1 .OR. !lAchMdfe

	// Busca as Rotas com o mesmo municipio de oriem e destino do roteiro
	If !Empty(aRotCli)
		cMunOri    := aRotCli[1,4]
		cEstOri    := aRotCli[1,5]
		nQtdTrecho := Len(aRotCli)
		cMunDes    := aRotCli[nQtdTrecho,4]
		cEstDes    := aRotCli[nQtdTrecho,5]	
	 
		//Busca todas as rotas que o roteiro se inicia no mesmo municipio de origem informa na tela de roteiro
		cQuery	:= " SELECT DJH.DJH_ROTA"
		
		cQuery	+= " FROM (	SELECT MIN(DDJ_SEQUEN)Minimo, "
		cQuery	+= " 	   			MAX(DDJ_SEQUEN)Maximo, "
		cQuery	+= " 	   			DDJ_ROTEIR "
		cQuery	+= " 			FROM " + RetSqlName("DDJ")
		cQuery	+= " 			WHERE D_E_L_E_T_ = ' ' "
		cQuery	+= " 				  AND DDJ_FILIAL 	= '"+ xFilial("DDJ")	+	"' "
		cQuery	+= " 			GROUP BY DDJ_ROTEIR "
		cQuery	+= " 		)TAB1 , " + RetSqlName("DDJ")+ " DDJ "
		
		cQuery	+= "  INNER JOIN  " + RetSqlName("DJH")+ " DJH "
		cQuery	+= "  ON 		DJH.DJH_FILIAL = '"+ FwxFilial("DJH") +"'  "
		cQuery	+= "  AND 		DJH.DJH_ROTEIR = DDJ.DDJ_ROTEIR"
		cQuery	+= "  AND 		DJH.D_E_L_E_T_ = ' ' "
		
		cQuery	+= "  INNER JOIN " +RetSqlName("DA8")+ " DA8 " 
		cQuery  += "  ON 		DA8.DA8_COD  		= DJH.DJH_ROTA "
		cQuery  += "  AND 		DA8.DA8_SERTMS 	= '" + cSerTms + 	"'"
		cQuery  += " AND 		DA8.DA8_ATIVO		= '1' "
		cQuery	+= "  AND 		DA8.D_E_L_E_T_ 	= ' ' "
		
		cQuery	+= "  WHERE TAB1.DDJ_ROTEIR = DDJ.DDJ_ROTEIR "
		cQuery	+= "        AND DDJ.DDJ_FILIAL 	= '"+ xFilial("DDJ")	+	"' "

		cQuery  += "        AND EXISTS (SELECT 0  FROM " + RetSqlName("DDJ")+ " DDJMIN "

		cQuery  += "                        INNER JOIN " + RetSqlName("SA1")+ " SA1 "
		cQuery  += "                        	ON  SA1.A1_FILIAL = '"+ FwxFilial("SA1") +"'"
		cQuery  += "                        	AND SA1.A1_COD = DDJMIN.DDJ_CLIENT "
		cQuery  += "                        	AND SA1.A1_LOJA = DDJMIN.DDJ_LOJA "
		cQuery  += "                        	AND SA1.D_E_L_E_T_ = ' ' "

		cQuery  += "                        LEFT JOIN " + RetSqlName("DUL")+ " DUL 	"
		cQuery  += "                        	ON  DUL_FILIAL ='"+ FwxFilial("DUL") +"'"
		cQuery  += "                        	AND DUL_CODCLI = DDJMIN.DDJ_CLIENT "
		cQuery  += "                        	AND DUL_LOJCLI = DDJMIN.DDJ_LOJA "
		cQuery  += "                        	AND DUL_SEQEND = DDJMIN.DDJ_SEQEND "
		cQuery  += "                        	AND DUL.D_E_L_E_T_ = ' '	"

		cQuery  += "                        WHERE DDJMIN.DDJ_FILIAL = '"+ FwxFilial("DDJ") +"'"
		cQuery  += "                        	AND DDJMIN.DDJ_ROTEIR = DDJ.DDJ_ROTEIR"
		cQuery  += "                        	AND DDJMIN.DDJ_SEQUEN = TAB1.MINIMO"
		cQuery  += "                        	AND CASE WHEN DDJ_SEQEND = '"+ Space(TamSx3('DDJ_SEQEND')[1]) + "' THEN SA1.A1_MUN ELSE DUL_MUN END = '"+ cMunOri +"'"
		cQuery  += "                        	AND CASE WHEN DDJ_SEQEND = '"+ Space(TamSx3('DDJ_SEQEND')[1]) + "' THEN SA1.A1_EST ELSE DUL_EST END = '"+ cEstOri +"'"
		cQuery  += "                        	AND DDJMIN.D_E_L_E_T_ = ' ') "
		
		cQuery += "         AND EXISTS (SELECT 0  FROM " + RetSqlName("DDJ")+ " DDJMAX"
        	   
		cQuery += "          				INNER JOIN " + RetSqlName("SA1")+ " SA1 "
		cQuery += "          					ON  SA1.A1_FILIAL = '"+ FwxFilial("SA1") +"'"
		cQuery += "          					AND SA1.A1_COD = DDJMAX.DDJ_CLIENT "
		cQuery += "          					AND SA1.A1_LOJA = DDJMAX.DDJ_LOJA "
		cQuery += "          					AND SA1.D_E_L_E_T_ = ' ' "
      					
		cQuery += "          				LEFT JOIN " + RetSqlName("DUL")+ " DUL 	"
		cQuery += "          					ON  DUL_FILIAL ='"+ FwxFilial("DUL") +"'"
		cQuery += "          					AND DUL_CODCLI = DDJMAX.DDJ_CLIENT "
		cQuery += "          					AND DUL_LOJCLI = DDJMAX.DDJ_LOJA "
		cQuery += "          					AND DUL_SEQEND = DDJMAX.DDJ_SEQEND "
		cQuery += "          					AND DUL.D_E_L_E_T_ = ' '	
	
		cQuery += "          				WHERE DDJMAX.DDJ_FILIAL = '"+ FwxFilial("DDJ") +"'"
		cQuery += "          					AND DDJMAX.DDJ_ROTEIR = DDJ.DDJ_ROTEIR"
		cQuery += "          					AND DDJMAX.DDJ_SEQUEN = TAB1.MAXIMO"
		cQuery += "          					AND CASE WHEN DDJ_SEQEND = '"+ Space(TamSx3('DDJ_SEQEND')[1]) + "' THEN SA1.A1_MUN ELSE DUL_MUN END = '"+ cMunDes +"'" 
		cQuery += "          					AND CASE WHEN DDJ_SEQEND = '"+ Space(TamSx3('DDJ_SEQEND')[1]) + "' THEN SA1.A1_EST ELSE DUL_EST END = '"+ cEstDes +"'"
		cQuery += "          					AND DDJMAX.D_E_L_E_T_ = ' ') "

		If Len(aPontMDFe) > 1 .AND. !lAchMdfe
			cQuery	+= " AND NOT EXISTS ( SELECT 0 FROM  " 	+ RetSqlName("DIQ") + " DIQ " 
			cQuery	+= "                   WHERE DIQ.DIQ_FILIAL = '" + Fwxfilial("DIQ") + "' " 	 
			cQuery += " 						AND	 DIQ.DIQ_ROTA   = DJH.DJH_ROTA "  
			cQuery += " 						AND	 DIQ.DIQ_ROTEIR <> '"+ Space(TamSx3('DIQ_ROTEIR')[1]) + "' "  
			cQuery += " 						AND	 DIQ.D_E_L_E_T_ = ' ' )"
		EndIf
		
		cQuery	+= "  GROUP BY DJH.DJH_ROTA"
		
		
		// Verificar se existe necessidade de incluir um campo na DDJ PARA identificar se o trecho se trata da origem/passagem ou destino do roteiro.
		cQuery := ChangeQuery(cQuery)
		
		dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQuery),cAliasBsc2, .F., .T.)
		
		// Preenche o Array de Rotas 
		While (cAliasBsc2)->(!Eof())
			If aScan( aVet , { |x| Alltrim(x[1]) == Alltrim((cAliasbsc2)->DJH_ROTA)}) == 0
				aAdd(aVet, {(cAliasbsc2)->DJH_ROTA,""})
			EndIf
			(cAliasBsc2)->(DbSkip())	  	
		EndDo
		
		(cAliasBsc2)->(dbCloseArea())
	
	EndIf
EndIf

Return(aVet)


/*/-----------------------------------------------------------
{Protheus.doc} F13BusRota
Busca Rotas do Roteiro

Uso: TMSF13

@sample
//F13BusRota(aRotei,cServTms,aPontMDFe, lDIQEmpty)

@author Paulo Henrique Corrêa Cardoso
@since 06/10/2016
@version 1.0
-----------------------------------------------------------/*/
Function F13BusRota(aRotei,cServTms,aPontMDFe, lDIQEmpty)
Local nCount       := 0   // Recebe  o contador 
Local cInRegRot    := ""  // Recebe 
Local cPontMDFe    := ""  // Recebe 
Local cAliasNew    := ""  // Recebe 
Local cQuery       := ""  // Recebe 
Local aRotas       := {}  // Recebe 

Default aRotei     := {}  // Recebe 
Default cServTms   := ""  // Recebe 
Default aPontMDFe  := {}  // Recebe 
Default lDIQEmpty  := .F. // Recebe 

// Busca as Rotas do Roteiro
If Len(aRotei) > 0

	For nCount := 1 To Len(aRotei)
		cInRegRot += Iif(Empty(cInRegRot),"",",") + aRotei[nCount]
	Next nCount
	
	
	For nCount := 1 To Len(aPontMDFe) 
		cPontMDFe += Iif(Empty(cPontMDFe),"",",") +  STRZERO( nCount , TamSx3('DIQ_SEQUEN')[1]) + aPontMDFe[nCount]
	Next nCount
	
	cAliasNew  := GetNextAlias()
	cQuery := " SELECT  DJH.DJH_ROTA, DJH_ROTEIR " 
	cQuery += " FROM " + RetSqlName("DJH") + " DJH "
	cQuery += " INNER JOIN  " 	+ RetSqlName("DA8") + " DA8 "
	cQuery += " ON 		DA8.DA8_FILIAL 	= '" + Fwxfilial("DA8") + "' " 	 
	cQuery += " AND 		DA8.DA8_COD  		= DJH.DJH_ROTA "  
	cQuery += " AND 		DA8.DA8_ATIVO		= '1' "
	cQuery += " AND 		DA8.DA8_SERTMS 	= '" + cServTms + 	"'"
	cQuery += " AND 		DA8.D_E_L_E_T_	= ' ' "
	
	If Len(aPontMDFe) > 1 .AND. !lDIQEmpty
		cQuery += " INNER JOIN  " 	+ RetSqlName("DIQ") + " DIQ "
		cQuery += " ON 		DIQ.DIQ_FILIAL 	= '" + Fwxfilial("DIQ") + "' " 	 
		cQuery += " AND 		DIQ.DIQ_ROTA 		= DJH.DJH_ROTA "  
		cQuery += " AND 		DIQ.DIQ_ROTEIR 		= DJH.DJH_ROTEIR "  	
		cQuery += " AND 		DIQ.D_E_L_E_T_	= ' ' "
			
		cQuery += " INNER JOIN (SELECT 	MAX(DIQ_SEQUEN)Maximo,  "
		cQuery += " 						DIQ_ROTA ,DIQ_ROTEIR "
		cQuery += " 				FROM " + RetSqlName("DIQ")
		cQuery += " 				WHERE D_E_L_E_T_ = ' ' "
		cQuery += " 		 			   AND DIQ_FILIAL 	= '" + xFilial("DIQ") + "' "
		cQuery += " 		 			   AND DIQ_ROTEIR <> '" + Space(TamSx3('DIQ_ROTEIR')[1]) + "' "
		cQuery += " 				GROUP BY DIQ_ROTA ,DIQ_ROTEIR "
		cQuery += "  				)TAB1 "
		cQuery += "  	ON TAB1.DIQ_ROTEIR  IN " + FormatIn( cInRegRot , "," )
		cQuery += "  	   AND TAB1.DIQ_ROTA = DJH.DJH_ROTA  "
	EndIf
					
	cQuery += " WHERE 	DJH.DJH_FILIAL 		= '" + xFilial("DJH") + "' "
	cQuery += " AND		DJH.DJH_ROTEIR IN " + FormatIn( cInRegRot , "," )
	cQuery += " AND 		DJH.D_E_L_E_T_	= ' ' "
	
	If Len(aPontMDFe) > 1 
		If lDIQEmpty // Considera apenas Rotas sem MDF-e
			cQuery	+= " AND NOT EXISTS ( SELECT 0 FROM  " 	+ RetSqlName("DIQ") + " DIQ " 
			cQuery	+= "                   WHERE DIQ.DIQ_FILIAL = '" + Fwxfilial("DIQ") + "' " 	 
			cQuery += " 						AND	 DIQ.DIQ_ROTA   = DJH.DJH_ROTA "  
			cQuery += " 						AND	 DIQ.DIQ_ROTEIR <> '"+ Space(TamSx3('DIQ_ROTEIR')[1]) + "' "  
			cQuery += " 						AND	 DIQ.D_E_L_E_T_ = ' ' )"		
		Else
			cQuery += " AND 		DIQ.DIQ_SEQUEN || DIQ.DIQ_EST IN  "
			cQuery +=  FormatIn( cPontMDFe , "," )  
			cQuery += " AND TAB1.Maximo = '" + StrZero(Len(aPontMDFe),TamSX3('DIQ_SEQUEN')[1] ) + "' "
		EndIf
	EndIf
			
	cQuery += " GROUP BY DJH.DJH_ROTA, DJH_ROTEIR "
	
	If Len(aPontMDFe) > 1 .AND. !lDIQEmpty
		cQuery += " HAVING COUNT(1) = " + cValToChar(Len(aPontMDFe))
	EndIf
	
	cQuery += " ORDER BY DJH.DJH_ROTA, DJH_ROTEIR"
	
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasNew,.F.,.T.)
	
	
	//Query de Rota Exatamente Igual	
	While (cAliasNew)->(!Eof())
		AADD(aRotas,{(cAliasNew)->DJH_ROTA,(cAliasNew)->DJH_ROTEIR})
		(cAliasNew)->(DbSkip())	 
	EndDo

	(cAliasNew)->(dbCloseArea())
	
EndIf

Return aRotas

/*/-----------------------------------------------------------
{Protheus.doc} TmsF13SugR
Busca roteiro identico na DDJ

Uso: TMSF13

@sample
//TmsF13SugR(aVet,cRota, cSerTms,aNewRot)

@author Kaiam
@since 08/04/2016
@version 1.0
-----------------------------------------------------------/*/
Function TmsF13SugR(aVet,cRota, cSerTms,aNewRot,oModel)

Local aCoors 		:= FWGetDialogSize(oMainWnd) 					
Local oDlg			                                 
Local oFWLayer
Local oPanelUp
Local oPanelDown  
Local aStru 		:= {}
Local cAliasArq 	:= GetNextAlias()
Local cIndexKey		:= ""
Local nI			:= 0
Local aColunas		:= {}
Local lRet			:= .F.
Local cTitulo		:= STR0014 //'Sugestao de Rotas'
Local lViagem		:= IsInCallStack('TMSA144Mnt') .AND. !IsInCallStack('TMSAF13Mnt')
Local cDescBtn	:= IIf(lViagem,STR0015,STR0016) //"Altera Rota"###"Confirmar"
Local aCamposRot	:= {}
Local nCount	    := 0

Local lDigRot       := TmsA144Sta("lDigRot")
Local oTempTable    := Nil
 
Default aVet 		:= {}
Default cRota		:= '' 
Default cSerTms	:= '1'
Default aNewRot	:= {}
Default oModel  := FwModelActive()

Private oMBrowseUp
Private oMBrowseDown           
Private aRotina  

If lDigRot
	If Ascan(aNewRot,{|x| x == M->DTQ_ROTA}) == 0 .And. Ascan(aVet,{|x| x[1] == M->DTQ_ROTA}) == 0
		Aadd(aNewRot,M->DTQ_ROTA)
	EndIf
EndIf

If !Empty(aVet) .OR. !Empty(aNewRot)

	// Monta a Estrutura de Campos 	
	aCamposRot := {"DA8_COD","DA8_DESC","DJG_ROTEIR","DA8_TIPROT","DA8_DESROT","DA8_CDRORI","DA8_SERVIC","DA8_SERTMS","DA8_DESSVT"}
	
	For nCount := 1 To Len(aCamposRot)
		aStructSx3 := TMSX3Cpo(aCamposRot[nCount])
		aAdd(aColunas,{aStructSx3[1] ,aCamposRot[nCount] ,aStructSx3[6],aStructSx3[3],aStructSx3[4],aStructSx3[5]})
		aAdd(aStru,{aCamposRot[nCount] ,aStructSx3[6],aStructSx3[3],aStructSx3[4]})	
		
		If aCamposRot[nCount] == "DA8_CDRORI"
			aStructSx3 := TMSX3Cpo("DA8_REGORI")
			aAdd(aColunas,{aStructSx3[1], "TMP_REGORI", "C", "@!", 1, aStructSx3[3], aStructSx3[4]})
			aAdd(aStru,{"TMP_REGORI", "C", aStructSx3[3], aStructSx3[4]})
		EndIf
		
		If aCamposRot[nCount] == "DA8_SERVIC"
			aStructSx3 := TMSX3Cpo("DA8_DESSER")
			aAdd(aColunas,{aStructSx3[1], "TMP_DESSER", "C", "@!", 1, aStructSx3[3], aStructSx3[4]})
			aAdd(aStru,{"TMP_DESSER", "C", aStructSx3[3], aStructSx3[4]})
		EndIf
	Next nCount
	
	aAdd(aStru,{"ORDEMBRW","C",1,0})
	
	//MONTA TABELA TEMPORÁRIA PARA UTILIZAÇÃO DO FWMBROWSE
	oTempTable := FWTemporaryTable():New(cAliasArq)
	oTempTable:SetFields( aStru )
	oTempTable:AddIndex("01", {"ORDEMBRW","DA8_COD","DJG_ROTEIR"} )
	oTempTable:Create()
			
	dbSelectArea("DA8")
	DA8->(dbSetOrder(1))	
	
	For nI := 1 To Len(aVet)
		If DA8->( dbSeek( FwxFilial("DA8")+ aVet[nI,1] )  )	
			If DA8->DA8_ATIVO == '1'
				RecLock(cAliasArq, .T.)		
				(cAliasArq)->DA8_COD 		:= DA8->DA8_COD 
				(cAliasArq)->DA8_DESC		:= DA8->DA8_DESC
				(cAliasArq)->DA8_TIPROT		:= DA8->DA8_TIPROT
				(cAliasArq)->DA8_CDRORI		:= DA8->DA8_CDRORI
				(cAliasArq)->DA8_SERVIC		:= DA8->DA8_SERVIC
				(cAliasArq)->DA8_SERTMS		:= DA8->DA8_SERTMS
				(cAliasArq)->DJG_ROTEIR		:= PadR( aVet[nI,2],TamSX3("DJG_ROTEIR")[1])
				(cAliasArq)->TMP_REGORI		:= POSICIONE("DUY",1,FwxFilial("DUY")+DA8->DA8_CDRORI,"DUY_DESCRI")
				(cAliasArq)->TMP_DESSER		:= Tabela("L4", DA8->DA8_SERVIC,.F.)
				(cAliasArq)->ORDEMBRW		:= IIf(Empty(aVet[nI,2]),"2","1")
				(cAliasArq)->(MsUnlock())
			EndIf
		EndIf
	Next nI
	
	// Insere a Rota que acabou de ser Adicionada 
	For nI := 1 To Len(aNewRot)
		If DA8->( dbSeek( FwxFilial("DA8")+ aNewRot[nI] )  )	
			RecLock(cAliasArq, .T.)		
			(cAliasArq)->DA8_COD 		:= DA8->DA8_COD 
			(cAliasArq)->DA8_DESC		:= DA8->DA8_DESC
			(cAliasArq)->DA8_TIPROT		:= DA8->DA8_TIPROT
			(cAliasArq)->DA8_CDRORI		:= DA8->DA8_CDRORI
			(cAliasArq)->DA8_SERVIC		:= DA8->DA8_SERVIC
			(cAliasArq)->DA8_SERTMS		:= DA8->DA8_SERTMS
			(cAliasArq)->DJG_ROTEIR		:= SPACE(TamSX3("DJG_ROTEIR")[1])
			(cAliasArq)->TMP_REGORI		:= POSICIONE("DUY",1,FwxFilial("DUY")+DA8->DA8_CDRORI,"DUY_DESCRI")
			(cAliasArq)->TMP_DESSER		:= Tabela("L4", DA8->DA8_SERVIC,.F.)
			(cAliasArq)->ORDEMBRW		:= Iif(lDigRot .And. DA8->DA8_COD == M->DTQ_ROTA,"0","2")
			(cAliasArq)->(MsUnlock())
		EndIf
	Next nI
	
	
	// FIM CRIACAO TABELA TEMPORARIA	

	DEFINE MSDIALOG oDlg TITLE cTitulo FROM aCoors[1],aCoors[2] TO aCoors[3],aCoors[4] PIXEL
	
		oFWLayer := FWLayer():New()
		oFWLayer:Init(oDlg,.F.,.T.)
		
		oFWLayer:AddLine("UP",50,.F.) 
		oFWLayer:AddCollumn("ALLDA8", 100, .T., 'UP' )     
		oPanelUp := oFWLayer:GetColPanel("ALLDA8", 'UP' )
		
		dbSelectArea(cAliasArq)
		dbGoTop()
		// Primeiro Browse - ROTAS
		oMBrowseUp:=FWMBrowse():New()
		oMBrowseUp:SetOwner( oPanelUp ) 
		oMBrowseUp:SetMenuDef( '' )  
		oMBrowseUp:SetDescription(STR0017)//Rotas
		oMBrowseUp:SetAlias(cAliasArq)
		oMBrowseUp:SetUseCaseFilter(.F.)
		oMBrowseUp:lFilter := .F.
		oMBrowseUp:lOptionReport := .F.
		//valida se a rota atual nao foi utilizada com o mesmo roteiro em uma outra viagem
		If !lViagem 
			oMBrowseUp:AddButton(cDescBtn, {|| TmsF13TOK1(@cRota,oMBrowseUp:GetColumnData(1)),lRet := .T.,oDlg:End()  },,2,,.F.)//Confirmar
			oMBrowseUp:AddButton(STR0018, {|| TF13GrRota( @cRota,cSerTms,aNewRot,oModel),lRet := .T.,oDlg:End() },,2,,.F.)//Nova Rota
		EndIf	
		oMBrowseUp:AddButton(STR0019, {|| oDlg:End() },,2,,.F.)//Fechar
		oMBrowseUp:AddButton(STR0020, {|| F13VisuRot(oMBrowseUp:GetColumnData(1)) },,2,,.F.)//Visualizar
			
		oMBrowseUp:SetFields(aColunas)
		oMBrowseUp:DisableDetails(.T.) 
		oMBrowseUp:Activate()
				
		// Segundo Browse - Rota X Rodovias
				
		oFWLayer:AddLine("DOWN", 50, .F. ) 
		oFWLayer:AddCollumn("ALLDU2", 100, .T., 'DOWN' )
		oPanelDown := oFWLayer:GetColPanel("ALLDU2", 'DOWN')
				
		oMBrowseDown := FWMBrowse():New() 
		oMBrowseDown:SetOwner( oPanelDown )
		oMBrowseDown:SetDescription(STR0021) // "Rota X Rodovias" 		   
		oMBrowseDown:SetAlias('DU2') 	
		oMBrowseDown:DisableConfig ( )    
		oMBrowseDown:SetMenuDef( '' )                  
	   	oMBrowseDown:SetCacheView (.F.)   
		oMBrowseDown:SetProfileID( '2' ) 		
		oMBrowseDown:DisableDetails(.T.) 		
		oMBrowseDown:lOptionReport := .F.
		oMBrowseDown:Activate() 		
		oMBrowseDown:DelColumn(2)
		oMBrowseDown:DelColumn(3)
		oMBrowseDown:SetUseCaseFilter(.F.)
		oMBrowseDown:UpdateBrowse()
						
		oRelation := FWBrwRelation():New()			 
		oRelation:AddRelation( oMBrowseUp, oMBrowseDown , {  {'DU2_ROTA', 'DA8_COD' } } )	
		oRelation:Activate()
	
	ACTIVATE MSDIALOG oDlg
EndIf

If Type('oTempTable') <> Nil
	oTempTable:Delete()
EndIf	
Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} TmsF13TOK1
Tudo OK Tela de Susgestao de Rotas

Uso: TMSF13

@sample
//TmsF13SugR(aVet,cRota, cSerTms,aNewRot,oModel)

@author Kaiam
@since 08/04/2016
@version 1.0
-----------------------------------------------------------/*/
Function TmsF13TOK1(cRota,cRotAtu)
Local lRet		:= .F.
Local oView 	:= Nil

Default cRota 	:= ''	
Default cRotAtu 	:= ''

DA8->(dbSetOrder(1))
If DA8->(dbSeek(FwxFilial('DA8')+cRotAtu))
	lRet := .T.
	M->DTQ_ROTA 	:= cRota := DA8->DA8_COD
	M->DTQ_DESROT := Posicione("DA8",1,xFilial("DA8") + M->DTQ_ROTA,"DA8_DESC")
EndIf	

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TF13GrRota
Preparação para gravação da Rota Automática
@author Leandro Paulino

@since 08/04/2016
@version 1.0	
/*/
//-------------------------------------------------------------------
Function TF13GrRota(cCodRota,cSerTms,aNewRot,oModelF12)

Local lRet			:= .T.
Local lIncl		:= .T.
Local nCntFor 	:= 0
Local cRecno		:= ''
Local cAliasQry	:= ''
Local cQuery		:= ''
Local aAreaDA8	:= DA8->(GetArea())
Local cServic		:= ''
Local cAtivSai 	:= SuperGetMV('MV_ATIVSAI',,'')
Local cAtivChg	:= SuperGetMV('MV_ATIVCHG',,'')
lOCAL cTarefa		:= ''
Local aAreaDC6	:= DC6->(GetArea())
Local aAreaDC5	:= DC5->(GetArea())
Local lAteraBkp	:= ALTERA
Local lIncluiBKP	:= INCLUI
//Pesquisar Atividades na DC6 e posteriormente procurá-las na DC5

Local aAreaSA1	 := SA1->(GetArea())
Local oMdGrdDJF  := NIL
Local cCodRegIni := ""
Local cCodRegFim := ""
Local oModel := NIL

Default cCodRota 	:= ''
Default cSerTms	:= ''
Default aNewRot	:= {}
Default oModelF12  := FwModelActive()


oMdGrdDJF  :=  oModelF12:GetModel("MdGridDJF1")
If Type("N") == "U"
	Private N := 0
EndIf
DA8->(dbSetOrder(1))
If Empty(cCodRota)

	cAliasQry := GetNextAlias()
	cQuery := " SELECT 	MAX(DA8_COD) DA8_COD			" 
	cQuery += "  			FROM " + RetSQLName("DA8") 
	
	cQuery += " WHERE 	DA8_FILIAL = '" + FwxFilial("DA8") + "' " 
	cQuery += "  			AND D_E_L_E_T_ = ' ' " 
	
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),(cAliasQry),.F.,.T.)  
	If (cAliasQry)->(!Eof())
		cCodRota := Soma1((cAliasQry)->DA8_COD)
	EndIf
	(cAliasQry)->(dbCloseArea())
	
	
EndIf
//--Busca os serviços das atividades dos parametros MV_ATVISAI e MV_ATIVCHG
If !Empty(cAtivSai) .And. !Empty(cAtivChg)
	
	cAliasQry:= GetNextAlias()
	
	cQuery := " SELECT 	DISTINCT DC5.DC5_SERVIC "
	
	cQuery += " FROM	" 			+ RetSqlName("DC6") + " DC6 " 
	
	cQuery += " INNER JOIN 	" 	+ RetSqlName("DC5") + " DC5 "
	cQuery += " 		ON		DC5.DC5_TAREFA = DC6.DC6_TAREFA "
	cQuery += " 		AND		DC5.DC5_SERTMS = '"+ cSerTms +"' "
	cQuery += " 		AND 	DC5.DC5_CATSER = '2' "
	cQuery += " 		AND		DC5.D_E_L_E_T_ = ' ' "		
			
	cQuery += " WHERE 	DC6.D_E_L_E_T_ = ' ' "
	cQuery += "			AND DC6.DC6_FILATI = '" + cFilAnt + "'
	cQuery += " 			AND DC6.DC6_ATIVID IN  ( '"+cAtivSai+"','"+cAtivChg+"')"				
	
	cQuery += " ORDER BY	DC5.DC5_SERVIC "			
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),(cAliasQry),.F.,.T.)
	If (cAliasQry)->(!Eof())
		cServic := (cAliasQry)->(DC5_SERVIC)
	EndIf
		
	(cAliasQry)->(dbCloseArea())

EndIf


Begin TransAction

	If ValType(oMdGrdDJF) == "O"
		For nCntFor := 1 To oMdGrdDJF:Length()
			oMdGrdDJF:GoLine(nCntFor) 
			If !oMdGrdDJF:IsDeleted()
				If Empty(cCodRegIni)
					If Empty(oMdGrdDJF:GetValue("DJF_SEQEND"))
						cCodRegIni := Posicione("SA1",1,xFilial("SA1") + oMdGrdDJF:GetValue("DJF_CLIENT") + oMdGrdDJF:GetValue("DJF_LOJA"),"A1_CDRDES")
					Else
						cCodRegIni := Posicione("DUL",2,xFilial("DUL") + oMdGrdDJF:GetValue("DJF_CLIENT") + oMdGrdDJF:GetValue("DJF_LOJA") + oMdGrdDJF:GetValue("DJF_SEQEND"),"DUL_CDRDES")
					EndIf
				EndIf
				If Empty(oMdGrdDJF:GetValue("DJF_SEQEND"))
					cCodRegFim := Posicione("SA1",1,xFilial("SA1") + oMdGrdDJF:GetValue("DJF_CLIENT") + oMdGrdDJF:GetValue("DJF_LOJA"),"A1_CDRDES")
				Else	
					cCodRegIni := Posicione("DUL",2,xFilial("DUL") + oMdGrdDJF:GetValue("DJF_CLIENT") + oMdGrdDJF:GetValue("DJF_LOJA") + oMdGrdDJF:GetValue("DJF_SEQEND") ,"DUL_CDRDES")
				EndIf
			EndIf
		Next nCntFor
	EndIf
	
	oModel := FwLoadModel('OMSA100')
	If ValType(oModel) == "O"
		ALTERA := .F.
		INCLUI := .T.
		 
		oModel:SetOperation(MODEL_OPERATION_INSERT)
		oModel:Activate()		
		oModel:GetModel( 'MdFieldCDA8' ):SetValue( 'DA8_FILIAL'	, FwxFilial('DA8')	)
		oModel:GetModel( 'MdFieldCDA8' ):SetValue( 'DA8_COD'		, cCodRota 			)
		oModel:GetModel( 'MdFieldCDA8' ):SetValue( 'DA8_DESC'	, "AUTO-"+cCodRota	)
		oModel:GetModel( 'MdFieldCDA8' ):SetValue( 'DA8_ATIVO'	, "1" 					)
		oModel:GetModel( 'MdFieldCDA8' ):SetValue( 'DA8_SERTMS'	, cSerTms				)

		oModel:GetModel( 'MdFieldCDA8' ):SetValue( 'DA8_CDRORI'	, cCodRegIni			) 

		If DA8->(ColumnPos("DA8_CDRCAL")) > 0
			oModel:GetModel( 'MdFieldCDA8' ):SetValue( 'DA8_CDRCAL'	, cCodRegFim			) 
		EndIf

		oModel:GetModel( 'MdFieldCDA8' ):SetValue( 'DA8_TIPTRA'	, "1"					) 
		oModel:GetModel( 'MdFieldCDA8' ):SetValue( 'DA8_TIPROT'	, "AU"					) 
		oModel:GetModel( 'MdFieldCDA8' ):SetValue( 'DA8_SERVIC'	, cServic				) 

		
		If FWExecView (, "OMSA100" , MODEL_OPERATION_INSERT , ,{|| .T. }, , , , , , , oModel ) == 0 //Clicou em COnfirmar 	

			DU2->(DbGoTo(0))
			DTZ->(DbGoTo(0))
			Inclui := .T.
			
			SaveInter()
			TMSA280(3,0,cCodRota,"AUTO-"+cCodRota)
			RestInter()
		
			AADD(aNewRot,cCodRota)
		Else
			cCodRota := ''			
		EndIf	
	Else
		cCodRota := ''		
	EndIf
	
	If ValType(oModel) <> 'U'			
		//--Destruir o modelo			
		oModel:Destroy()
	EndIf
	
End Transaction

ALTERA := lAteraBkp
INCLUI := lIncluiBKP
RestArea(aAreaDA8)
RestArea(aAreaDC5)
RestArea(aAreaDC6)
RestArea(aAreaSA1)

Return cCodRota

//-------------------------------------------------------------------
/*/{Protheus.doc} F13VisuRot
Abre a tela de rotas para visualização 
@author Paulo Henrique Corrêa Cardoso

@since 28/06/2016
@version 1.0	
/*/
//-------------------------------------------------------------------
Function F13VisuRot(cRotAtu)
Local aArea		:= GetArea()
Local aAreaDA8	:= DA8->(GetArea())

Default cRotAtu 	:= ''

DA8->(dbSetOrder(1))
If DA8->(dbSeek(FwxFilial('DA8')+cRotAtu))
	FWExecView( STR0022 ,'OMSA100',MODEL_OPERATION_VIEW,, { || .T. },{ || .T. },,,{ || .T. }) //"Rota"
EndIf

RestArea(aAreaDA8)
RestArea(aArea)

Return


