#include "protheus.ch"
#include "report.ch"
#include "AGRAR650.ch"

//---------------------------------------------------------------------
/*/{Protheus.doc} AGRAR650
Função de relatorio de Fardos por Bloco
@author Leonardo Quintania
@since 21/06/2013
@version MP11
/*/
//---------------------------------------------------------------------

Function AGRAR650()
Local oReport
Local cPerg := "AGRAR650"  
Private aTotais := {0,0}
Private aContador := 0           
If FindFunction("TRepInUse") .And. TRepInUse()
	
	Pergunte(cPerg,.F.)
		
	oReport:= ReportDef()
	oReport:PrintDialog()	
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Função de definição do layout e formato do relat?io

@return oReport	Objeto criado com o formato do relat?io
@author Leonardo Quintania
@since 21/06/2013
@version MP11
/*/
//-------------------------------------------------------------------
Static Function ReportDef()
	Local oReport	:= NIL
	Local oSection1	:= NIL
	Local oSection2	:= NIL
	
	Private cAliasRel := ""
	
	DEFINE REPORT oReport NAME "AGRAR650" TITLE STR0001 PARAMETER "AGRAR650" ACTION {|oReport| PrintReport(oReport)}
	
	oReport:lParamPage = .F.  //Imprime os parametros
	oReport:SetCustomText( {|| AG650MoCab(oReport, mv_par01 ) } )
	
	If Funname() = "AGRA650"
		oReport:ParamReadOnly(.t.)
		oReport:HideParamPage()
	Endif
	
	DEFINE SECTION oSection1 OF oReport TABLES "DXI" LINE STYLE
	
	oSection1:SetPageBreak(.T.)
	oSection1:ShowHeader(.F.)	//Define se apresenta titulo da seção
	
	DEFINE CELL NAME "DXI_BLOCO" OF oSection1 ALIGN CENTER PICTURE "@!" TITLE "BLOCO" SIZE 10    //Fardo
	
	DEFINE BREAK oBreak OF oSection1 WHEN oSection1:Cell("DXI_BLOCO")
	
	//----------------------------
	// Dados Gerais
	//----------------------------
	DEFINE SECTION oSection2 OF oReport TITLE STR0002 TABLES "DXI"
	
	DEFINE CELL NAME "DXI_CODIGO1" 	OF oSection2 HEADER ALIGN CENTER ALIGN CENTER PICTURE "" TITLE STR0003 SIZE 10    //Fardo
	DEFINE CELL NAME "DXI_CLACOM1"	OF oSection2 HEADER ALIGN CENTER ALIGN CENTER PICTURE "" TITLE STR0004 SIZE 10    //Tipo
	DEFINE CELL NAME "DXI_PESO1" 	OF oSection2 HEADER ALIGN CENTER ALIGN CENTER PICTURE "" TITLE STR0005 SIZE 10    //Peso
	DEFINE CELL NAME "DXI_PRENSA1" 	OF oSection2 HEADER ALIGN CENTER ALIGN CENTER PICTURE "" TITLE STR0006 SIZE 10    //Prensa
	
	DEFINE CELL NAME "DXI_CODIGO2" 	OF oSection2 HEADER ALIGN CENTER ALIGN CENTER PICTURE "" TITLE STR0003 SIZE 10    //Fardo
	DEFINE CELL NAME "DXI_CLACOM2"	OF oSection2 HEADER ALIGN CENTER ALIGN CENTER PICTURE "" TITLE STR0004 SIZE 10    //Tipo
	DEFINE CELL NAME "DXI_PESO2" 	OF oSection2 HEADER ALIGN CENTER ALIGN CENTER PICTURE "" TITLE STR0005 SIZE 10    //Peso
	DEFINE CELL NAME "DXI_PRENSA2" 	OF oSection2 HEADER ALIGN CENTER ALIGN CENTER PICTURE "" TITLE STR0006 SIZE 10    //Prensa
	
	DEFINE CELL NAME "DXI_CODIGO3" 	OF oSection2 HEADER ALIGN CENTER ALIGN CENTER PICTURE "" TITLE STR0003 SIZE 10    //Fardo
	DEFINE CELL NAME "DXI_CLACOM3"	OF oSection2 HEADER ALIGN CENTER ALIGN CENTER PICTURE "" TITLE STR0004 SIZE 10    //Tipo
	DEFINE CELL NAME "DXI_PESO3" 	OF oSection2 HEADER ALIGN CENTER ALIGN CENTER PICTURE "" TITLE STR0005 SIZE 10    //Peso
	DEFINE CELL NAME "DXI_PRENSA3" 	OF oSection2 HEADER ALIGN CENTER ALIGN CENTER PICTURE "" TITLE STR0006 SIZE 10    //Prensa
	
	DEFINE CELL NAME "DXI_CODIGO4" 	OF oSection2 HEADER ALIGN CENTER ALIGN CENTER PICTURE "" TITLE STR0003 SIZE 10    //Fardo
	DEFINE CELL NAME "DXI_CLACOM4"	OF oSection2 HEADER ALIGN CENTER ALIGN CENTER PICTURE "" TITLE STR0004 SIZE 10    //Tipo
	DEFINE CELL NAME "DXI_PESO4" 	OF oSection2 HEADER ALIGN CENTER ALIGN CENTER PICTURE "" TITLE STR0005 SIZE 10    //Peso
	DEFINE CELL NAME "DXI_PRENSA4" 	OF oSection2 HEADER ALIGN CENTER ALIGN CENTER PICTURE "" TITLE STR0006 SIZE 10    //Prensa
		
	// CELL  BORDER  
	DEFINE CELL BORDER OF oSection2 EDGE_ALL  
	
	// CELL HEADER BORDER  
	DEFINE CELL HEADER BORDER OF oSection2 EDGE_ALL 

Return oReport

//-------------------------------------------------------------------
/*/{Protheus.doc} PrintReport
Função para busca das informações que ser? impressas no relat?io

@param oReport	Objeto para manipulação das seções, atributos e dados do relat?io.
@return void
@author Leonardo Quintania
@since 21/06/2013
@version MP11
/*/
//-------------------------------------------------------------------
Static Function PrintReport(oReport)
Local oDados     := oReport:Section(2)
Local cWhere     := ""
Local cWhereDXI  := ""
Local cAliasDXI  := GetNextAlias()


#IFDEF TOP
		
IF !Funname() = "AGRA650"	
	cWhere := if (!Empty(mv_par01),"AND DXI.DXI_SAFRA  = '"+mv_par01+"'","")
	cWhere += if (!Empty(mv_par02),"AND DXI.DXI_PRDTOR = '"+mv_par02+"'","")
	cWhere += if (!Empty(mv_par03),"AND DXI.DXI_LJPRO  = '"+mv_par03+"'","")
	cWhere += if (!Empty(mv_par04),"AND DXI.DXI_BLOCO  = '"+mv_par04+"'","")
	
	If !Empty(mv_par09)
		cWhere += " AND DXI.DXI_CODUNB = '" + mv_par09 + "' "
		cWhereDXI += " AND DXI.DXI_CODUNB = '" + mv_par09 + "' "
	Endif	

	If mv_par06 == 1 //Disponivel
		cWhere += " AND DXI.DXI_ROMSAI = ' '"
		cWhereDXI += " AND DXI.DXI_ROMSAI = ' '"
	ElseIf mv_par06 == 2 //Não disponivel
		cWhere += " AND DXI.DXI_ROMSAI <> ' '"
		cWhereDXI += " AND DXI.DXI_ROMSAI <> ' '"
	EndIf
	
	If mv_par07 == 1 //Reservado
		cWhere += " AND DXI.DXI_CODRES  <> ' '"
		cWhereDXI += " AND DXI.DXI_CODRES  <> ' '"
	ElseIf mv_par07 == 2 //Não Reservado
		cWhere += " AND DXI.DXI_CODRES = ' '"
		cWhereDXI += " AND DXI.DXI_CODRES = ' '"
	EndIf

	If mv_par08 == 1 //Entregues
		cWhere += " AND DXI.DXI_ROMSAI <> ' '"
		cWhereDXI += " AND DXI.DXI_ROMSAI <> ' '"
	ElseIf mv_par08 == 2 //Não Entregues
		cWhere += " AND DXI.DXI_ROMSAI = ' '"
		cWhereDXI += " AND DXI.DXI_ROMSAI = ' '"
	EndIF	
Else
 	cWhereDXI := ""
 	
	cWhere := "AND DXI.DXI_SAFRA = '"+DXD->DXD_SAFRA+"'"
	cWhere += "AND DXI.DXI_BLOCO  = '"+DXD->DXD_CODIGO+"'"
Endif	
	
	cWhere    := "%"+cWhere+"%"	
	cWhereDXI := "%"+cWhereDXI+"%" 
	
	//Alias seção 2
	cAliasRel:= GetNextAlias()
	
	BeginSql Alias cAliasDXI
		SELECT DXI_SAFRA, DXI_BLOCO 
		FROM %table:DXI% DXI		      	
		WHERE DXI.%notDel% AND 
		DXI.DXI_FILIAL = %xFilial:DXI% 
		%Exp:cWhere% 
		GROUP BY DXI_SAFRA, DXI_BLOCO
			
	EndSql 
		
	While (cAliasDXI)->(!Eof())
		
		If !Empty((cAliasDXI)->DXI_BLOCO)
													
			BeginSql Alias cAliasRel
				SELECT *
				FROM %table:DXI% DXI		      	
				WHERE DXI.DXI_FILIAL = %xFilial:DXI%
					AND DXI.DXI_SAFRA = %exp:(cAliasDXI)->DXI_SAFRA% 
					AND DXI.DXI_BLOCO = %exp:(cAliasDXI)->DXI_BLOCO%
					AND DXI.%notDel%  
					%Exp:cWhereDXI%
				ORDER BY DXI_SAFRA, DXI_CODIGO	
			EndSql 
			
			aTotais[1] := 0
			aTotais[2] := 0
			
			oDados:Init()
			
			oReport:PrintText("")
			oReport:PrintText("BLOCO" + " : " + Transform((cAliasDXI)->DXI_BLOCO,"@!"),,10) 
			oReport:PrintText("")
			oReport:PrintText("")
						
			While (cAliasRel)->(!Eof())
							
				oDados:Cell("DXI_CODIGO1"):SetValue( (cAliasRel)->( DXI_CODIGO )  )
				oDados:Cell("DXI_CLACOM1"):SetValue(  AllTrim(Transform((cAliasRel)->( DXI_CLACOM ), PesqPict("DXI", "DXI_CLACOM")))  )
				oDados:Cell("DXI_PESO1"):SetValue( If ( mv_par05== 1 , AllTrim(Transform((cAliasRel)->( DXI_PSBRUT ), PesqPict("DXI", "DXI_PSBRUT"))) ,  AllTrim(Transform((cAliasRel)->( DXI_PSLIQU ), PesqPict("DXI", "DXI_PSLIQU"))) ) )
				oDados:Cell("DXI_PRENSA1"):SetValue( (cAliasRel)->( DXI_PRENSA )  )
				totaliza()
				(cAliasRel)->( dbSkip() ) 
				
				If (cAliasRel)->(!Eof())
					oDados:Cell("DXI_CODIGO2"):SetValue( (cAliasRel)->( DXI_CODIGO )  )
					oDados:Cell("DXI_CLACOM2"):SetValue(  AllTrim(Transform((cAliasRel)->( DXI_CLACOM ), PesqPict("DXI", "DXI_CLACOM")))  )
					oDados:Cell("DXI_PESO2"):SetValue( If ( mv_par05== 1 , AllTrim(Transform((cAliasRel)->( DXI_PSBRUT ), PesqPict("DXI", "DXI_PSBRUT"))) ,  AllTrim(Transform((cAliasRel)->( DXI_PSLIQU ), PesqPict("DXI", "DXI_PSLIQU"))) ) )
					oDados:Cell("DXI_PRENSA2"):SetValue( (cAliasRel)->( DXI_PRENSA )  )
					totaliza()
					(cAliasRel)->( dbSkip() )
				Else
					oDados:Cell("DXI_CODIGO2"):SetValue( "" )
					oDados:Cell("DXI_CLACOM2"):SetValue( "" )
					oDados:Cell("DXI_PESO2"):SetValue( "" )
					oDados:Cell("DXI_PRENSA2"):SetValue( "" )	
				EndIf
				
				If (cAliasRel)->(!Eof())
					oDados:Cell("DXI_CODIGO3"):SetValue( (cAliasRel)->( DXI_CODIGO )  )
					oDados:Cell("DXI_CLACOM3"):SetValue(  AllTrim(Transform((cAliasRel)->( DXI_CLACOM ), PesqPict("DXI", "DXI_CLACOM")))  )
					oDados:Cell("DXI_PESO3"):SetValue( If ( mv_par05== 1 , AllTrim(Transform((cAliasRel)->( DXI_PSBRUT ), PesqPict("DXI", "DXI_PSBRUT"))) ,  AllTrim(Transform((cAliasRel)->( DXI_PSLIQU ), PesqPict("DXI", "DXI_PSLIQU"))) ) )
					oDados:Cell("DXI_PRENSA3"):SetValue( (cAliasRel)->( DXI_PRENSA )  )		
					totaliza()
					(cAliasRel)->( dbSkip() ) 
				Else
					oDados:Cell("DXI_CODIGO3"):SetValue( "" )
					oDados:Cell("DXI_CLACOM3"):SetValue( "" )
					oDados:Cell("DXI_PESO3"):SetValue( "" )
					oDados:Cell("DXI_PRENSA3"):SetValue( "" )	
				EndIf
				
				If (cAliasRel)->(!Eof())
					oDados:Cell("DXI_CODIGO4"):SetValue( (cAliasRel)->( DXI_CODIGO )  )
					oDados:Cell("DXI_CLACOM4"):SetValue(  AllTrim(Transform((cAliasRel)->( DXI_CLACOM ), PesqPict("DXI", "DXI_CLACOM")))  )
					oDados:Cell("DXI_PESO4"):SetValue( If ( mv_par05== 1 , AllTrim(Transform((cAliasRel)->( DXI_PSBRUT ), PesqPict("DXI", "DXI_PSBRUT"))) ,  AllTrim(Transform((cAliasRel)->( DXI_PSLIQU ), PesqPict("DXI", "DXI_PSLIQU"))) ) )
					oDados:Cell("DXI_PRENSA4"):SetValue( (cAliasRel)->( DXI_PRENSA )  )
					totaliza()
					(cAliasRel)->( dbSkip() ) 
				Else
					oDados:Cell("DXI_CODIGO4"):SetValue( ""  )
					oDados:Cell("DXI_CLACOM4"):SetValue( ""  )
					oDados:Cell("DXI_PESO4"):SetValue( "" )
					oDados:Cell("DXI_PRENSA4"):SetValue( "" )	
				EndIf
				oDados:PrintLine()
			EndDo
			oDados:Finish()
			oDados:SetPageBreak(.T.)
			
			(cAliasRel)->(DBCloseArea())
				
			oReport:PrintText("")
			oReport:PrintText("")	
			oReport:PrintText(STR0008 + " : " + Transform(aTotais[1],"@E 99,999,999,999"),,10) 
			oReport:PrintText(STR0007 + " : " + Transform(aTotais[2],"@E 99,999,999,999.99"),,10)
				
		Endif
		dbSelectArea(cAliasDXI)  
		(cAliasDXI)->( dbSkip() )	 
	EndDo
		
	(cAliasDXI)->(DBCloseArea())
#ENDIF

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AG650MoCab
Função para montar cabecalho do relatorio  

@param oReport Objeto para manipulação das seções, atributos e dados do relat?io.
@return aCabec  Array com o cabecalho montado
@author Leonardo Quintania
@since 21/06/2013
@version MP11
/*/
//-------------------------------------------------------------------

Static Function AG650MoCab(oReport, cSafra)
	Local aCabec 	:= {}
	Local cNmEmp  	:= ""   
	Local cNmFilial  	:= ""   
	Local cChar		:= CHR(160)  // caracter dummy para alinhamento do cabe?lho
	
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
	aCabec[3] += Space(9) + STR0009 + Dtoc(dDataBase)   // Direita
	
	// Linha 4
	AADD(aCabec, RptHora + oReport:cTime) //Esquerda
	//aCabec[4] += Space(9) + "BLOCO:"+MV_PAR04 // Meio
	aCabec[4] += Space(9) + RptEmiss + oReport:cDate   // Direita
	
	// Linha 5
	AADD(aCabec, STR0010 + cNmEmp) //Esquerda
	aCabec[5] += Space(9) // Meio
	If !Empty(cSafra)
		aCabec[5] += Space(9)+ STR0011 + cSafra   // Direita
	EndIf     
	// Linha 5
	AADD(aCabec, STR0012 + cNmFilial) //Esquerda

Return aCabec

//-------------------------------------------------------------------
/*/{Protheus.doc} AjusteSX1
Função para totalizar peso bruto e líquido
@since 
@version MP11
/*/
//-------------------------------------------------------------------

Static Function Totaliza()
	aTotais[1]	+= 1
	If  mv_par05== 1
		aTotais[2] += (cAliasRel)->DXI_PSBRUT
	else
		aTotais[2] += (cAliasRel)->DXI_PSLIQU
	endif	
Return
