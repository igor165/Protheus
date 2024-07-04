#INCLUDE "Protheus.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "LOJR850.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJR850   บAutor  ณMicrosiga           บ Data ณ  02/17/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRelatorio de Vendas Analitico - Lista de Presentes          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function LOJR850 ()

Local cPerg  	:= "LOJR850" 							             	//Pergunte
Local cAlias	:= GetNextAlias()                                      //Alias temporario
Local lLstPre   := SuperGetMV("MV_LJLSPRE",.T.,.F.) .AND.;            //Valida se a funcionalidade esta ativa
					 IIf(FindFunction("LjUpd78Ok"),LjUpd78Ok(),.F.)
Local oReport  															//Objeto do relatorio
Local oSection1															//Objeto Secao 1
Local oSection2 														//Objeto Secao 2
Local oBrkSec2                                                          //Objeto de quebra

If !lLstPre
	MsgAlert(STR0001)//"O recurso de lista de presente nใo estแ ativo ou nใo foi devidamente aplicado e/ou configurado, impossํvel continuar!"
    Return .F.
Endif

#IFDEF TOP
		
	Pergunte(cPerg,.T.)
	
	
	//ฺฤฤฤฤฤฤฤฤฤฟ
	//ณRelatorioณ
	//ภฤฤฤฤฤฤฤฤฤู
	DEFINE REPORT oReport NAME "LOJR850" TITLE STR0002 PARAMETER cPerg ACTION {|oReport| PrintReport(oReport, cPerg, cAlias)} //"Relat๓rio de Vendas Analitico - Lista de Presentes"
	oReport:SetLandscape() //Escolher o padrใo de Impressao como Paisagem  	
	oReport:nFontBody   := 9
	oReport:nLineHeight := 50
	oReport:cFontBody   := "Arial"
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSessao Pai - Quebraณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	If MV_PAR10 == 1 //Data da Venda
		DEFINE SECTION oSection1 OF oReport TITLE STR0003 BREAK HEADER LINE STYLE//"Data da Venda"
		DEFINE CELL NAME "L1_EMISNF" OF oSection1 TITLE STR0003 SIZE 40 // "Data da Venda"    
  	ElseIf MV_PAR10 == 2 //Filial	  
   		DEFINE SECTION oSection1 OF oReport TITLE STR0004 BREAK HEADER LINE STYLE //"Filial"
		DEFINE CELL NAME "FILIAL" OF oSection1 TITLE STR0004 SIZE 20 BLOCK {||Posicione("SM0",1,(cAlias)->ME4_EMPMOV+(cAlias)->ME4_FILMOV,"M0_FILIAL")}// "Filial"       		
  	EndIf
   		     
	   	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณSessao Filha - Detalhesณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		DEFINE SECTION oSection2 OF oSection1 TITLE STR0005 BREAK HEADER AUTO SIZE	//"Vendas"
   		
   		If MV_PAR10 == 1 //Data da Venda
			DEFINE CELL NAME "FILIAL" 		OF oSection2 TITLE STR0004 SIZE 14 BLOCK {||Posicione("SM0",1,(cAlias)->ME4_EMPMOV+(cAlias)->ME4_FILMOV,"M0_FILIAL")}// "Filial"       					
   		ElseIf MV_PAR10 == 2 //Filial	  			
			DEFINE CELL NAME "L1_EMISNF" 	OF oSection2 TITLE STR0006 	SIZE 12// "Data"       		   		
   		EndIf
   		
   		DEFINE CELL NAME "RECEP"		OF oSection2 TITLE STR0007		SIZE 40 BLOCK {||Rtrim((cAlias)->ME2_VEND)+" - "+Rtrim((cAlias)->RECEP)}//"Recep. Lista"
   		DEFINE CELL NAME "A3_NOME"		OF oSection2 TITLE STR0008		SIZE 40 BLOCK {||Rtrim((cAlias)->L2_VEND)+" - "+Rtrim((cAlias)->A3_NOME)}//"Vendedor"
		DEFINE CELL NAME "TIPO"	   		OF oSection2 TITLE STR0009		SIZE 25 BLOCK {||LJR850X3Bx((cAlias)->ME1_TIPO,"ME1_TIPO")}//"Tp. Lista"        
		DEFINE CELL NAME "ME1_STATUS"	OF oSection2 TITLE STR0010		SIZE 12 BLOCK {||LJR850X3Bx((cAlias)->ME1_STATUS,"ME1_STATUS")}//"Status"		
		DEFINE CELL NAME "ME4_DOC"		OF oSection2 TITLE STR0011		SIZE 35	BLOCK {||Rtrim((cAlias)->ME4_DOC) + "-" +Rtrim((cAlias)->ME4_SERIE)}//"Documento"
		DEFINE CELL NAME "A1_NOME"		OF oSection2 TITLE STR0012 		SIZE 38 //"Convidado"
		DEFINE CELL NAME "ME4_CODIGO"	OF oSection2 TITLE STR0013 		SIZE 20 //"Lista"		
		DEFINE CELL NAME "ME2_DESCRI"	OF oSection2 TITLE STR0014		SIZE 45 BLOCK {||Rtrim((cAlias)->ME2_PRODUT)+" - "+Rtrim((cAlias)->ME2_DESCRI)}//"Produto" 	    
		DEFINE CELL NAME "ME4_QUANT"	OF oSection2 TITLE STR0015		PICTURE PesqPict("ME1","ME1_CODIGO") AUTO SIZE //"Qtde."
		DEFINE CELL NAME "L2_VRUNIT"	OF oSection2 TITLE STR0016		SIZE 28 //"Vlr.Unit."		
		DEFINE CELL NAME "ME4_VALOR"	OF oSection2 TITLE STR0017 		SIZE 30 //"Vlr.Venda"
        
		//ฺฤฤฤฤฤฤฤฤฤฤฟ
		//ณSub-Totaisณ
		//ภฤฤฤฤฤฤฤฤฤฤู
		If MV_PAR10 == 1 //Data da Venda
			oBrkSec2 := TRBreak():New(oSection2, {||oSection1:Cell("L1_EMISNF")},STR0018)//"Sub-Total do dia "		
		ElseIf MV_PAR10 == 2 //Filial
			oBrkSec2 := TRBreak():New(oSection2, {||oSection1:Cell("FILIAL")},STR0019)//"Sub-Total da filial "	
		EndIf
				
		TRFunction():New(oSection2:Cell("ME4_VALOR"),NIL,"SUM",oBrkSec2,Upper(STR0020),,,.F.,.T.)//"Total de Vendas"  
		oReport:PrintDialog()
#ELSE
	MsgStop (STR0021)//"Relat๓rio incompatํvel para este tipo de banco de dados !"

#ENDIF
Return Nil 



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPrintReportบAutor  ณLeandro Nogueira   บ Data ณ  18/02/11   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณSelecao dos itens a serem impressos                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ oReport - Objeto do Relat๓rio							  บฑฑ
ฑฑบ			   cPerg   - Cadastro de Perguntas para o Filtro do Relat๓rio บฑฑ
ฑฑบ			   cAlias1 - Area para o Select da Primeira Se็ใo - Cabe็alho บฑฑ
ฑฑบ			   cAlias2 - Area para o Select da Segunda  Se็ใo - Particip. บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLOJR850                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PrintReport(oReport, cPerg, cAlias)

Local oSection1 	:= oReport:Section(1)                          //Define a secao Pai (Quebra)
Local oSection2     := oReport:Section(1):Section(1)	           	//Define a secao Filha (Detalhe)  
Local cEndQuery		:= ""                                          	//Complemento da Query executada no banco
Local cTipLista		:= ""                                          	//Tipos de lista que serao exibidas
Local cFilialA3     := xFilial("SA3")                               //Filtro por Filial

Default oReport 	:= NIL
Default cPerg		:=""
Default cAlias		:=""

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณParametro - Filial ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !Empty(MV_PAR01) .OR. !Empty(MV_PAR02)
	cEndQuery += 	" AND (ME4_FILMOV BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "') "           
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณParametro - Periodo de Vendaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !Empty(MV_PAR03)//Data De:
   	cEndQuery += " AND L1_EMISNF >= '" + DToS(MV_PAR03) + "' "
EndIf

If !Empty(MV_PAR04)//Data At้:
	cEndQuery += " AND L1_EMISNF <= '" + DToS(MV_PAR04) + "' "
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณParametro - Tipo de Lista ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If MV_PAR05 <> 4 
    cEndQuery += " AND ME1_TIPO = '" + AllTrim(Str(MV_PAR05)) + "' "
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณParametro - Lista    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !Empty(MV_PAR06) .OR. !Empty(MV_PAR07)
	cEndQuery += 	" AND (ME4_CODIGO BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR07 + "') "           
Endif


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณParametro - Vendedor ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !Empty(MV_PAR08) .OR. !Empty(MV_PAR09)
	cEndQuery += 	" AND (L2_VEND BETWEEN '" + MV_PAR08 + "' AND '" + MV_PAR09 + "') "           
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณParametro - Quebra de relatorioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If MV_PAR10 == 1 //Data da Venda
	cEndQuery+= " ORDER BY L1_EMISNF,ME4_EMPMOV,ME4_FILMOV,ME4_CODIGO,ME4_DOC"
ElseIf MV_PAR10 == 2 //Filial	  
	cEndQuery+= " ORDER BY ME4_EMPMOV,ME4_FILMOV,L1_EMISNF,ME4_CODIGO,ME4_DOC"	
EndIf


cEndQuery := "%"+cEndQuery+"%"

MakeSqlExpr(cPerg) 

BEGIN REPORT QUERY oSection1
	BeginSQL alias cAlias   
		SELECT
			ME4.ME4_EMPMOV,
			ME4.ME4_FILMOV,
			ME2.ME2_VEND,
			SL1.L1_EMISNF,
			SL2.L2_VEND,
			SA3.A3_NOME,
			ME4.ME4_CODIGO,
			ME1.ME1_TIPO,
			ME1.ME1_STATUS,
			ME4.ME4_DOC,
			ME4.ME4_SERIE,
			ME4.ME4_NOMCLI A1_NOME,
			ME2.ME2_PRODUT,
			ME2.ME2_DESCRI,
			ME4.ME4_QUANT,
			SL2.L2_VRUNIT,
			ME4.ME4_VALOR,
			ME1.ME1_VEND, 
			SL1.L1_VLRTOT,
			SA31.A3_NOME AS RECEP
		FROM 
			%table:ME4% ME4	
			INNER JOIN %table:ME1% ME1 ON ME1.ME1_CODIGO = ME4.ME4_CODIGO AND ME1.%notDel%
			LEFT  JOIN %table:ME2% ME2 ON ME2.ME2_CODIGO = ME4.ME4_CODIGO AND  ME2.ME2_PRODUT = ME4.ME4_COD AND ME2.%notDel%
			INNER JOIN %table:SL2% SL2 ON SL2.L2_FILIAL=ME4_FILMOV AND SL2.L2_NUM = ME4_NUMORC AND SL2.L2_ITEM = ME4_ITORC AND SL2.%notDel%
		    INNER JOIN %table:SL1% SL1 ON SL1.L1_NUM = SL2.L2_NUM AND SL1.%notDel%
			INNER JOIN %table:SA3% SA3 ON SA3.A3_COD = SL2.L2_VEND AND SA3.A3_FILIAL = %Exp:cFilialA3% AND SA3.%notDel%
			INNER JOIN %table:SA3% SA31 ON SA31.A3_COD = ME2.ME2_VEND AND SA31.A3_FILIAL = %Exp:cFilialA3% AND SA31.%notDel%
		WHERE
			ME4.%notDel% AND
			ME4_TIPO = 1 AND
			ME4_TIPREG <> 2 %Exp:cEndQuery%
	EndSql
END REPORT QUERY oSection1 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณBaseada na query da secao1, utiliza filtro para saber quando deve sair do laco de impressaoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

oSection2:SetParentQuery()

If MV_PAR10 == 1 //Data da Venda
	oSection2:SetParentFilter( { |cParam|	(cAlias)->L1_EMISNF == cParam },	{|| (cAlias)->L1_EMISNF}  )
ElseIf MV_PAR10 == 2 //Filial	  
	oSection2:SetParentFilter( { |cParam|	(cAlias)->ME4_EMPMOV+ME4_FILMOV == cParam },	{|| (cAlias)->ME4_EMPMOV+ME4_FILMOV}  )	
EndIf

oSection1:SetEdit(.F.)
oSection1:SetHeaderSection(.T.)	  
oSection1:Print()    

oSection2:SetHeaderSection(.T.)	  
oSection2:Print()  


Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJR850X3BxบAutor  ณLeandro Noguira     บ Data ณ  25/02/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna a descri็ใo do combo box do campo no SX3            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametro ณ cCodigo	- Codigo do combo								  บฑฑ
ฑฑบ          ณ cCamp	- campo a ser exibido							  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLOJR848                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LJR850X3Bx (cCodigo,cCampo)                                       

Local aSX3Box	:= {}	//Array de Opcoes do Combo Box
Local cRet  	:= ""  	//Retorno
Local nPos		:= 0   	//Posicao do array    

Default cCodigo	:= ""
Default cCampo	:= ""

If !Empty(Posicione("SX3", 2, cCampo, "X3CBox()" ))
	aSX3Box	:= RetSx3Box( Posicione("SX3", 2, cCampo, "X3CBox()" ),,, 1 )
	
	nPos := Ascan(aSX3BOX,{|x| x[2]== cCodigo})
	If nPos > 0 
		cRet:= aSX3Box[nPos,3]
	Endif
Endif

If Empty(cRet)
	cRet := cCodigo
Endif

Return Rtrim(cRet)   
