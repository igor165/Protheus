#INCLUDE "agrar600.ch"
#include "protheus.ch"
#include "report.ch"

//Pula Linha
#DEFINE CTRL Chr(13)+Chr(10)

//-------------------------------------------------------------------
/*/{Protheus.doc} AGRAR600
Fun��o de relatorio de Romaneio de entrada
@author Leonardo Quintania
@since 21/06/2013
@version MP11
/*/
//-------------------------------------------------------------------


Function AGRAR600()
Local oReport
           
If FindFunction("TRepInUse") .And. TRepInUse()
	//������������������������������������������������������������������������Ŀ
	//�Interface de impress�o                                                  �
	//��������������������������������������������������������������������������
	oReport:= ReportDef("REPORT")
	oReport:PrintDialog()	
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Fun��o de defini��o do layout e formato do relat�rio

@return oReport	Objeto criado com o formato do relat�rio
@author Leonardo Quintania
@since 21/06/2013
@version MP11
/*/
//-------------------------------------------------------------------

Static Function ReportDef()
Local oReport		:= NIL
Local oSection1	:= NIL
Local oSection2	:= NIL
Local oSection3	:= NIL

Private cAliasRel	:= ""

DEFINE REPORT oReport NAME "AGRAR600" TITLE STR0001 PARAMETER "REPORT" ACTION {|oReport| PrintReport(oReport)} //"Romaneio de Entrada"
oReport:SetCustomText( {|| AG600MoCab(oReport, &(cAliasRel+"->DXM_SAFRA") ) } )
oReport:lParamPage = .F.  //N�o imprime os parametros

//�����������������������������������������������������������������������Ŀ
//�"Cabecalho Romaneio"                                                   �
//�������������������������������������������������������������������������
DEFINE SECTION oSection1 OF oReport TITLE STR0001 TABLES "DXM" LINE STYLE //"Romaneio de Entrada"

DEFINE BORDER OF oSection1 EDGE_BOTTOM WEIGHT 2 

DEFINE CELL NAME "cEmpresa" 	OF oSection1 TITLE STR0002 SIZE 25 CELL BREAK //Empresa //"Empresa"
DEFINE CELL NAME "DXM_CODIGO" 	OF oSection1 SIZE 25 
DEFINE CELL NAME "DXM_SAFRA"	OF oSection1 SIZE 10
DEFINE CELL NAME "DXM_DTEMIS"	OF oSection1 SIZE 10 CELL BREAK
DEFINE CELL NAME "NJ0_NOME"		OF oSection1 ALIAS "NJ0" AUTO SIZE CELL BREAK
DEFINE CELL NAME "NJ0_CGC"		OF oSection1 ALIAS "NJ0" SIZE 20 
DEFINE CELL NAME "NJ0_INSCR"  	OF oSection1 ALIAS "NJ0" SIZE 20 CELL BREAK
DEFINE CELL NAME "NN2_NOME"  	OF oSection1 TITLE STR0003 AUTO SIZE BLOCK {|| POSICIONE("NN2",3,FWxFilial("NN2")+(cAliasRel)->(DXM_PRDTOR+DXM_LJPRO+DXM_FAZ) ,"NN2_NOME") }  CELL BREAK  //"FAZENDA"
DEFINE CELL NAME "DXM_NOTA" 	OF oSection1 SIZE 30 CELL BREAK //Nota Fiscal
DEFINE CELL NAME "DXM_PLACA" 	OF oSection1 SIZE 30 CELL BREAK	//Placa
DEFINE CELL NAME "DXM_MOTORA" 	OF oSection1 SIZE 30 CELL BREAK //Motorista

//�����������������������������������������������������������������������Ŀ
//�"Dados Gerais" 		                                                    �
//�������������������������������������������������������������������������
DEFINE SECTION oSection2 OF oReport TITLE STR0004 TABLES "DXM" AUTO SIZE //"Dados Gerais"

DEFINE BORDER OF oSection2 EDGE_BOTTOM WEIGHT 2

DEFINE CELL NAME "DXL_PRENSA" 	OF oSection2 BLOCK {|| POSICIONE("DXL",1,FWxFilial("DXL")+(cAliasRel)->DX0_FARDAO,"DXL_PRENSA") } //Prensa
DEFINE CELL NAME "DX0_ITEM" 	OF oSection2 //Item
DEFINE CELL NAME "DX0_FARDAO" 	OF oSection2 //Fardao
DEFINE CELL NAME "DX0_CODPRO" 	OF oSection2 //Produto
DEFINE CELL NAME "NNV_DESCRI" 	OF oSection2 TITLE "Variedade" BLOCK {|| POSICIONE("NNV",1,FWxFilial("NNV")+(cAliasRel)->DX0_CODPRO + (cAliasRel)->DX0_CODVAR,"NNV_DESCRI") } //Variedade
DEFINE CELL NAME "DX0_TALHAO" 	OF oSection2 //Talhao
DEFINE CELL NAME "DX0_RATEIO" 	OF oSection2 //Rateio
DEFINE CELL NAME "DX0_PSLIQU" 	OF oSection2 //Peso Liquido

//�����������������������������������������������������������������������Ŀ
//�"Pesos" 				                                                    �
//�������������������������������������������������������������������������
DEFINE SECTION oSection3 OF oReport TITLE STR0005 TABLES "DXM" LINE STYLE //"Pesos Romaneio"

DEFINE BORDER OF oSection3 EDGE_BOTTOM WEIGHT 2

DEFINE CELL NAME "DXM_PSBRUT" 	OF oSection3 TITLE "( + ) PESO BRUTO"  	ALIAS "DXM" SIZE 19 ALIGN RIGHT CELL BREAK //Peso Bruto 
DEFINE CELL NAME "DXM_PSTARA" 	OF oSection3 TITLE "( - ) PESO TARA"	ALIAS "DXM" SIZE 20 ALIGN RIGHT CELL BREAK //Peso Tara
DEFINE CELL NAME "DXM_SUBTOT"	OF oSection3 TITLE "( = ) SUB TOTAL"	ALIAS "DXM" PICTURE PesqPict("DXM","DXM_PSBRUT") SIZE 20 ALIGN RIGHT CELL BREAK // Sub Total Peso Bruto - Peso Tara
DEFINE CELL NAME "DXM_PSLONA"	OF oSection3 TITLE "( - ) PESO LONA" 	ALIAS "DXM" SIZE 20 ALIGN RIGHT CELL BREAK //Peso Lona
DEFINE CELL NAME "DXM_PSLIQU"	OF oSection3 TITLE "( = ) PESO LIQUIDO" ALIAS "DXM" SIZE 17 ALIGN RIGHT CELL BREAK // Sub Total - Peso Lona

DEFINE CELL NAME STR0006 OF oSection3 TITLE STR0007 BOLD SIZE 50 CELL BREAK // "Pesagem"###"Pesagem efetuada por balanca eletr�nica"

DEFINE CELL NAME "DXM_OBS" 	OF oSection3 ALIAS "DXM" AUTO SIZE BLOCK {||DXM->DXM_OBS}  //Observacao

Return oReport

//-------------------------------------------------------------------
/*/{Protheus.doc} PrintReport
Fun��o para busca das informa��es que ser�o impressas no relat�rio

@param oReport	Objeto para manipula��o das se��es, atributos e dados do relat�rio.
@return void
@author Leonardo Quintania
@since 21/06/2013
@version MP11
/*/
//-------------------------------------------------------------------
Static Function PrintReport(oReport)
Local oCab		 := oReport:Section(1)
Local oDados	 := oReport:Section(2)
Local oPesos	 := oReport:Section(3)
Local cNomeEmp := AllTrim(FwFilialName(,cFilAnt,2))
Local cUN      := ""

cUN := A655GETUNB( )

#IFDEF TOP
	//�����������������������������Ŀ
	//�Query do relatorio da secao 1�
	//�������������������������������
	
	If !Empty(cUN)
		Begin Report Query oCab   
		
			cAliasRel:= GetNextAlias()
		
			BeginSql Alias cAliasRel
				SELECT *
				FROM %table:DXM% DXM,
				     %table:NJ0% NJ0
				WHERE DXM.DXM_FILIAL = %xFilial:DXM%     AND
					DXM.DXM_PRDTOR = NJ0.NJ0_CODENT        AND
					DXM.DXM_LJPRO  = NJ0.NJ0_LOJENT        AND
					DXM.DXM_CODIGO = %Exp:DXM->DXM_CODIGO% AND
					DXM.DXM_CODUNB = %Exp:cUN%             AND
					DXM.%notDel%	                         AND
					NJ0.%notDel%				
			EndSql 
	
		End Report Query oCab
	Else
		Begin Report Query oCab   
	
			cAliasRel:= GetNextAlias()
		
			BeginSql Alias cAliasRel
				SELECT *
				FROM %table:DXM% DXM,
				     %table:NJ0% NJ0
				WHERE DXM.DXM_FILIAL = %xFilial:DXM%     AND
					DXM.DXM_PRDTOR = NJ0.NJ0_CODENT        AND
					DXM.DXM_LJPRO  = NJ0.NJ0_LOJENT        AND
					DXM.DXM_CODIGO = %Exp:DXM->DXM_CODIGO% AND
					DXM.%notDel%	                         AND
					NJ0.%notDel%				
			EndSql 
	
		End Report Query oCab
	Endif
	//����������������������������Ŀ
	//� Imprime dados do Cabacalho �
	//������������������������������
	oCab:Init()
	oCab:Cell("cEmpresa"):SetValue( cNomeEmp )
	oCab:PrintLine()
	oCab:Finish()
	(cAliasRel)->(DBCloseArea())
	
	//��������������������������������Ŀ
	//�Query do relatorio da secao 2   �
	//����������������������������������
	If !Empty(cUN)	
		Begin Report Query oDados   
		
			cAliasRel:= GetNextAlias()
			
			BeginSql Alias cAliasRel
				SELECT *
				FROM %table:DXM% DXM,
				     %table:DX0% DX0
				      	
				WHERE DXM.DXM_FILIAL = %xFilial:DXM%      AND
					DX0.DX0_FILIAL = %xFilial:DX0%     	 AND
					DXM.DXM_CODIGO = DX0.DX0_CODROM        AND 
					DXM.DXM_CODIGO = %Exp:DXM->DXM_CODIGO% AND
					DXM.DXM_CODUNB = %Exp:cUN%             AND
					DXM.%notDel%	                         AND
					DX0.%notDel%	 				
			EndSql 
	
		End Report Query oDados
	Else
		Begin Report Query oDados   
	
			cAliasRel:= GetNextAlias()
			
			BeginSql Alias cAliasRel
				SELECT *
				FROM %table:DXM% DXM,
				     %table:DX0% DX0
				      	
				WHERE DXM.DXM_FILIAL = %xFilial:DXM%      AND
					DX0.DX0_FILIAL = %xFilial:DX0%     	 AND
					DXM.DXM_CODIGO = DX0.DX0_CODROM        AND 
					DXM.DXM_CODIGO = %Exp:DXM->DXM_CODIGO% AND
					DXM.%notDel%	                         AND
					DX0.%notDel%	 				
			EndSql 
	
		End Report Query oDados
			
	Endif
	//��������������������������Ŀ
	//� Imprime dados gerais		 �
	//����������������������������
	oDados:Init()
	oDados:Print()
	oDados:Finish()
	(cAliasRel)->(DBCloseArea())
	
	//���������������������������������Ŀ
	//�Query do relatorio do Pesos	     �
	//�����������������������������������
	If !Empty(cUN)
	
		Begin Report Query oPesos   
		
			cAliasRel:= GetNextAlias()
			
			BeginSql Alias cAliasRel
				SELECT (DXM.DXM_PSBRUT-DXM.DXM_PSTARA) AS DXM_SUBTOT, DXM.*
				FROM %table:DXM% DXM
				WHERE DXM.DXM_FILIAL = %xFilial:DXM%      AND
					DXM.DXM_CODIGO = %Exp:DXM->DXM_CODIGO% AND
					DXM.DXM_CODUNB = %Exp:cUN%             AND
					DXM.%notDel%					
			EndSql 
	
		End Report Query oPesos	
	Else
		Begin Report Query oPesos   
	
			cAliasRel:= GetNextAlias()
			
			BeginSql Alias cAliasRel
				SELECT (DXM.DXM_PSBRUT-DXM.DXM_PSTARA) AS DXM_SUBTOT, DXM.*
				FROM %table:DXM% DXM
				WHERE DXM.DXM_FILIAL = %xFilial:DXM%      AND
					DXM.DXM_CODIGO = %Exp:DXM->DXM_CODIGO% AND
					DXM.%notDel%					
			EndSql 
	
		End Report Query oPesos	
		
	Endif
	
	//��������������������������Ŀ
	//� Imprime dados de Pesos	 �
	//����������������������������
	oPesos:Init()
	oPesos:Print()
	oPesos:Finish()
	(cAliasRel)->(DBCloseArea())
	
#ENDIF

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AG750MoCab
Fun��o para montar cabecalho do relatorio  

@param oReport Objeto para manipula��o das se��es, atributos e dados do relat�rio.
@return aCabec  Array com o cabecalho montado
@author Leonardo Quintania
@since 21/06/2013
@version MP11
/*/
//-------------------------------------------------------------------

Function AG600MoCab(oReport, cSafra)
Local aCabec 	:= {}
Local cNmEmp  	:= ""   
Local cNmFilial  	:= ""   
Local cChar		:= CHR(160)  // caracter dummy para alinhamento do cabe�alho

Default cSafra := ""

If SM0->(Eof())
	SM0->( MsSeek( cEmpAnt + cFilAnt , .T. ))
Endif

cNmEmp	:= AllTrim( SM0->M0_NOME )
cNmFilial	:= AllTrim( SM0->M0_FILIAL )

// Linha 1
AADD(aCabec, "__LOGOEMP__") // Esquerda

// Linha 2 
AADD(aCabec, cChar) //Esquerda
aCabec[2] += Space(9) // Meio
aCabec[2] += Space(9) + RptFolha + TRANSFORM(oReport:Page(),'999999') // Direita

// Linha 3
AADD(aCabec, "SIGA /" + oReport:ReportName() + "/v." + cVersao) //Esquerda
aCabec[3] += Space(9) + oReport:cRealTitle // Meio
aCabec[3] += Space(9) + STR0008 + Dtoc(dDataBase)   // Direita //"Dt.Ref:"

// Linha 4
AADD(aCabec, RptHora + oReport:cTime) //Esquerda
aCabec[4] += Space(9) // Meio
aCabec[4] += Space(9) + RptEmiss + oReport:cDate   // Direita

// Linha 5
AADD(aCabec, STR0009 + cNmEmp) //Esquerda //"Empresa:"
aCabec[5] += Space(9) // Meio
If !Empty(cSafra)
	aCabec[5] += Space(9)+ STR0010+cSafra   // Direita //"Safra:"
EndIf     

// Linha 5
AADD(aCabec, STR0011 + cNmFilial) //Esquerda //"Filial:"

Return aCabec