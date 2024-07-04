#include "protheus.ch"
#include "DAOTPE.ch"
Static oTmpTableOr
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DaotPE    ³ Autor ³ 		Bruno Schmidt		³ Data ³17/07/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Funcion que monta y alimenta el archivo de trabajo. Se      ³±±
±±³          ³crearan dos archivos: Costos.txt  e Ingresos.txt            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³dAnoEje    - Año de ejecución                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³Data    ³ BOPS     ³ Motivo da Alteracao                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alf. Medrano³29/12/16³SERINN001-530³creación de tablas temporales con  ³±±
±±³            ³        ³          ³FWTemporaryTable y se corrige STR en  ³±±
±±³            ³        ³          ³declaracion de dDataDe se limpia obj. ³±±
±±³            ³        ³          ³en func. DaotPE                       ³±±
±±³Alf. Medrano³17/01/17³SERINN001-530³Merge Main vs 12.1.15              ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DaotPE(dAnoEje,cFilini,cFilFin,cForn1,cLoja1,cForn2,cLoja2)
Local nX,nY,nI   := 0
Local aStr	     := {}
Local aPagCob	 := {} 	 //Detalhe das sordens de pagamento / titulos  
Local lNotOk     := .F.
Local aTMP       := {}   
Local lEsJurid   := .F.    
Local nConsec    := 0  //Consecutivo para los registros
Local cTPPers    := "" //Tipo Persona 
Local nPropor    := 0      
Local cNamePat   := ""
Local cNameMat   := ""
Local cNamePes   := ""   
Local cTpDoco    := ""      
Local cRazonS    := ""
Local cPaisPrv   := ""
Local cQuery		:= ""
Local aSF1SAI := {}
Local aSF1ENT :={}
Local aSF2SAI := {}
Local aSF2ENT :={}
Local aSelFil := {}
Local cFilEmp :=""
local aArea   :="" 
local cRUC := ""

Private aTotRel  := {}
Private nOpRelMex:= 0
Private nUITS      := 0
Private cFiltroTRB := ""
Private bFiltroTRB := {||}


Default dDataDe	 := Ctod("01/01/" +  str(dAnoEje),"DDMMYYYY")
Default dDataAte := Ctod("31/12/" + str(dAnoEje),"DDMMYYYY")


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta la tabla TRB para impresion³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

/*
Tabla1  TIPO DE DOCUMENTO     

COD DESCRIPCION
1	Libreta Electoral/DNI
2 	Carnet de Fuerzas policiales
3 	Carnet de Fuerzas armadas
4	Carnet de Extranjera
6	Registro Unico de Constribuyentes
7	Pasaporte
*/

/*
Tabla2  TIPO PERSONA     

COD DESCRIPCION
01	Persona Natural
02 	Persona Juridica o Entidades
03 	Sujeto no domiciliado
04  Adquiriente o ticket
*/


aAdd (aStr, {"TRB_ITEM",	    "N",	05	,		0})   //1-Consecutivo
aAdd (aStr, {"TRB_TPDOCE",	    "C",	01	,		0})   //6-RUC    (FIJO)
aAdd (aStr, {"TRB_NODOCE",		"C",	18	,		0})   //GGGGGGG  (A2_CGC)
aAdd (aStr, {"TRB_PERIOD",		"N",	04	,		0})   //2013 - Periodo a declarar (MV_PAR01)
aAdd (aStr, {"TRB_TPPERO",		"C",	02	,		0})   //01 - Tp Persona (A2_TIPO)
aAdd (aStr, {"TRB_TPDOCO",		"C",	01	,		0})   //6-RUC    (FIJO)
aAdd (aStr, {"TRB_NODOCO",		"C",	18	,		0})   //PPPPPPP  (A2_CGC)
aAdd (aStr, {"TRB_IMPTE",		"N",	18	,		0})   //
aAdd (aStr, {"TRB_APEPAT",		"C",	40	,		0})   //APELLIDO PATERNO
aAdd (aStr, {"TRB_APEMAT",		"C",	40	,		0})   //APELLIDO MATERNO 
aAdd (aStr, {"TRB_NOME1",		"C",	40	,		0})	   //NOMBRE
aAdd (aStr, {"TRB_NOME2",		"C",	40	,		0})	   //NOMBRE2
aAdd (aStr, {"TRB_RAZON",		"C",	40	,		0})	   //NOMBRE2  (A2_NOME)
aAdd (aStr, {"TRB_PAIS",		"C",	03	,		0})	   //Pais    (A2_PAIS)
//
cArq	:=	CriaTrab(,.F.)
AADD(aTMP,{cArq,"TRB"})

oTmpTableOr := FWTemporaryTable():New("TRB")
oTmpTableOr:SetFields( aStr ) 
//crea indice
oTmpTableOr:AddIndex('T1ORD', {'TRB_NODOCE'})
//Creacion de la tabla
oTmpTableOr:Create()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtra as filias que serao processadas                                                                 ³
//³O array aFilsCalc eh gerado na execucao 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aArea:= SM0->(GetArea())
While SM0->M0_CODIGO+SM0->M0_CODFIL >= (Subs(cNumEmp,1,2)+cFilini) .And. 	SM0->M0_CODIGO+SM0->M0_CODFIL <= (Subs(cNumEmp,1,2)+cFilFin)
		aAdd(aSelFil,SM0->M0_CODFIL)
	SM0->(DbSkip())	
EndDO

RestArea(aArea)


#IFDEF TOP
	cQuery += "SELECT F1_FORNECE,F1_LOJA,F1_ESPECIE,F1_TPDOC,F1_FILIAL, "
	cQuery += "SUM (CASE WHEN F1_MOEDA = 1 THEN F1_VALMERC ELSE (F1_VALMERC* F1_TXMOEDA) END) TOTVALSF1 "
	cQuery += " FROM " + RetSqlName("SF1") +" SF1 "	// Cabecalho de NFE Entrada
	cQuery += " Where "
	cQuery += " F1_FILIAL " + GetRngFil(aSelFil,"SF1")+ ""
	cQuery += " AND F1_EMISSAO >= '" + Dtos(dDataDe) + "'"
	cQuery += " AND F1_EMISSAO <= '" + Dtos(dDataAte) + "'"
	cQuery += " AND F1_TPDOC NOT IN (99,00) ""
	cQuery += " AND SF1.D_E_L_E_T_=''"
	cQuery += " GROUP BY F1_FORNECE,F1_LOJA,F1_ESPECIE,F1_TPDOC,F1_FILIAL"

	cAlias := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPSF1",.T.,.T.)
	
	cQuery := ""
	cQuery += "SELECT F2_CLIENTE,F2_LOJA,F2_ESPECIE,F2_FILIAL, "
	cQuery += " SUM(CASE WHEN F2_MOEDA = 1 THEN F2_VALMERC ELSE (F2_VALMERC* F2_TXMOEDA) END) TOTVALSF2 "
	cQuery += " FROM " + RetSqlName("SF2")+" SF2 "	// Cabecalho de NFE Saida
	cQuery += " Where"
	cQuery += " F2_FILIAL " + GetRngFil(aSelFil,"SF2")+ ""
	cQuery += " AND F2_EMISSAO >= '" + Dtos(dDataDe) + "'"
	cQuery += " AND F2_EMISSAO <= '" + Dtos(dDataAte) + "'"
	cQuery += " AND F2_TPDOC NOT IN (99,00) ""
	cQuery += " AND SF2.D_E_L_E_T_=''"
	cQuery += " GROUP BY F2_CLIENTE,F2_LOJA,F2_ESPECIE,F2_FILIAL"

	cAlias := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPSF2",.T.,.T.)
#ENDIF  


While !TMPSF1->(Eof())


cFilEmp:= xFilial("SA1")

If !empty(cFilEmp)
	cFilEmp := TMPSF1->F1_FILIAL
End



SA2->(DbSetOrder(1))
SA2->(MsSeek(cFilEmp+TMPSF1->F1_FORNECE+TMPSF1->F1_LOJA))

IF Alltrim(SA2->A2_EST) == "EX" .or. (TMPSF1->F1_TPDOC == "02" .and. SUBSTRING(SA2->A2_CGC,1,1) = '1' .and. SA2->A2_TIPO = '2') 
 	// Quando for agente de autonomos de 4a Categoria nao e gerado e Fornecedor e Cliente diferente de EX
Else	
	If (Alltrim(TMPSF1->F1_ESPECIE) == 'NDP' .or. Alltrim(TMPSF1->F1_ESPECIE) == 'NF') 
		nReg := Ascan(aSF1ENT,{|x| x[1] == TMPSF1->F1_FORNECE })
	ElseIf (Alltrim(TMPSF1->F1_ESPECIE) == 'NCC' .or. Alltrim(TMPSF1->F1_ESPECIE) == 'NDE')  
		nReg := Ascan(aSF1SAI,{|x| x[1] == TMPSF1->F1_FORNECE }) 
	EndIf
	
		Do case					
			Case nReg = 0 .and. (Alltrim(TMPSF1->F1_ESPECIE) == 'NDP' .or. Alltrim(TMPSF1->F1_ESPECIE) == 'NF')
				Aadd(aSF1ENT,{"","","","","",""}) 
				If len(aSF1ENT) = 1
					nx:=1
				Else
					nx:= nx+1
				EndIf
				aSF1ENT[nx][1]:= TMPSF1->F1_FORNECE
				aSF1ENT[nx][2]:= Alltrim(TMPSF1->F1_ESPECIE)
				aSF1ENT[nx][3]:= TMPSF1->F1_LOJA
				aSF1ENT[nx][4]:= TMPSF1->F1_TPDOC
				aSF1ENT[nx][6]:= TMPSF1->TOTVALSF1
				
			Case  nReg = 0  .and. (Alltrim(TMPSF1->F1_ESPECIE) == 'NCC' .or. Alltrim(TMPSF1->F1_ESPECIE) == 'NDE') 
				Aadd(aSF1SAI,{"","","","","",""}) 
				If len(aSF1SAI) = 1
					ny:=1
				Else
					ny:= ny + 1
				EndIf
				aSF1SAI[ny][1]:= TMPSF1->F1_FORNECE
				aSF1SAI[ny][2]:= Alltrim(TMPSF1->F1_ESPECIE)
				aSF1SAI[ny][3]:= TMPSF1->F1_LOJA
				aSF1SAI[ny][4]:= TMPSF1->F1_TPDOC
				aSF1SAI[ny][6]:= TMPSF1->TOTVALSF1
				
			Case nReg > 0 .and. (Alltrim(TMPSF1->F1_ESPECIE) == 'NDP' .or. Alltrim(TMPSF1->F1_ESPECIE) == 'NF')
				aSF1ENT[nReg][6]+= TMPSF1->TOTVALSF1	
			Case nReg > 0 .and. (Alltrim(TMPSF1->F1_ESPECIE) == 'NCC' .or. Alltrim(TMPSF1->F1_ESPECIE) == 'NDE')	
				aSF1SAI[nReg][6]+= TMPSF1->TOTVALSF1
		EndCase
EndIf
	
TMPSF1->(DbSkip())
EndDO


While !TMPSF2->(Eof())

cFilEmp:= xFilial("SA2")

If !empty(cFilEmp)
	cFilEmp := TMPSF2->F2_FILIAL 
End

SA1->(DbSetOrder(1))
SA1->(MsSeek(cFilEmp+TMPSF2->F2_CLIENTE+TMPSF2->F2_LOJA))



IF Alltrim(SA1->A1_EST) <> "EX" 
	If (Alltrim(TMPSF2->F2_ESPECIE) == 'NDC' .or. Alltrim(TMPSF2->F2_ESPECIE) == 'NF') 
		nReg := Ascan(aSF2ENT,{|x| x[1] == TMPSF2->F2_CLIENTE })
	ElseIf (Alltrim(TMPSF2->F2_ESPECIE) == 'NCP' .or. Alltrim(TMPSF2->F2_ESPECIE) == 'NDI')  
		nReg := Ascan(aSF2SAI,{|x| x[1] == TMPSF2->F2_CLIENTE }) 
	EndIf
	
		Do case					
			Case nReg = 0 .and. (Alltrim(TMPSF2->F2_ESPECIE) == 'NDC' .or. Alltrim(TMPSF2->F2_ESPECIE) == 'NF') 
				Aadd(aSF2ENT,{"","","","",""}) 
				If len(aSF2ENT) = 1
					nx:=1
				Else
					nx:= nx+1
				EndIf
				aSF2ENT[nx][1]:= TMPSF2->F2_CLIENTE
				aSF2ENT[nx][2]:= Alltrim(TMPSF2->F2_ESPECIE)
				aSF2ENT[nx][3]:= TMPSF2->F2_LOJA
				aSF2ENT[nx][5]:= TMPSF2->TOTVALSF2
				
			Case  nReg = 0  .and. (Alltrim(TMPSF2->F2_ESPECIE) == 'NCP' .or. Alltrim(TMPSF2->F2_ESPECIE) == 'NDI')   
				Aadd(aSF2SAI,{"","","","",""}) 
				If len(aSF2SAI) = 1
					ny:=1
				Else
					ny:= ny + 1
				EndIf
				aSF2SAI[ny][1]:= TMPSF2->F2_CLIENTE
				aSF2SAI[ny][2]:= Alltrim(TMPSF2->F2_ESPECIE)
				aSF2SAI[ny][3]:= TMPSF2->F2_LOJA
				aSF2SAI[ny][5]:= TMPSF2->TOTVALSF2
				
			Case nReg > 0 .and. (Alltrim(TMPSF2->F2_ESPECIE) == 'NDC' .or. Alltrim(TMPSF2->F2_ESPECIE) == 'NF') 
				aSF2ENT[nReg][5]+= TMPSF2->TOTVALSF2	
			Case nReg > 0 .and. (Alltrim(TMPSF2->F2_ESPECIE) == 'NCP' .or. Alltrim(TMPSF2->F2_ESPECIE) == 'NDI')  
				aSF2SAI[nReg][5]+= TMPSF2->TOTVALSF2	
		EndCase
EndIf
	
TMPSF2->(DbSkip())
EndDO



If  nRutina == 1 //COSTOS (SA2)
	For nX := 1 to Len(aSF1ENT)
		For ny := 1 to Len(aSF2SAI)
			nReg := Ascan(aSF2SAI,{|x| x[1] == aSF1ENT[nX][1] })
			If nReg = ny
				aSF1ENT[nX][6] := aSF1ENT[nX][6] - aSF2SAI[ny][5]
			EndIf
		Next ny
	
		SA2->(DbSetOrder(1))
		If  SA2->(DbSeek(xFilial("SA2")+aSF1ENT[nX][1]+aSF1ENT[nX][3]))     
			 //Tomar los datos del proveedor
			If  SA2->A2_TIPO == "1"  //Es persona Juridica (RAZON SOCIAL)
				lEsJurid := .T.
				cRUC     := SA2->A2_CGC
				cTPPers  := "02"  //Persona Jurica o Entidades
			ElseIf  SA2->A2_TIPO == "2"  //Es persona Natural (NOMBRE)
				cRUC     := SA2->A2_CGC //SA2->A2_PFISICA
				lEsJurid := .F.
				cTPPers  := "01"  //Persona Natural
			Else  //Sujeto no domiciliado
				cTPPers  := "03"  //Sujeto no domiciliado
			Endif
		Endif
		// Gravação
		
		If !(TRB->(DbSeek(cRUC)))
			lNotOk := .T.          //Insertar
			RecLock("TRB",.T.)    
			nConsec ++    
			
			TRB->TRB_ITEM    := nConsec
			TRB->TRB_PERIOD  := dAnoEje
			//DECLARANTE					
			TRB->TRB_TPDOCE  := "6"
			TRB->TRB_NODOCE  := SM0->M0_CGC					        
			//DECLARADO   
			TRB->TRB_TPPERO  := cTPPers
			TRB->TRB_TPDOCO  := Alltrim(Str(VAL(SA2->A2_TIPDOC)))
			TRB->TRB_NODOCO  := cRUC
			If  lEsJurid               
				TRB->TRB_RAZON  := SA2->A2_NOME		
			Else
				TRB->TRB_APEPAT := AllTrim(SA2->A2_NOMEPAT) 
				TRB->TRB_APEMAT := AllTrim(SA2->A2_NOMEMAT) 
				TRB->TRB_NOME1  := Alltrim(Substr(SA2->A2_NOMEPES,1,AT(" ",SA2->A2_NOMEPES)))
				TRB->TRB_NOME2  := Alltrim(Substr(SA2->A2_NOMEPES,AT(" ",SA2->A2_NOMEPES),len(SA2->A2_NOMEPES)))
			EndIf
			TRB->TRB_IMPTE	:= aSF1ENT[nX][6]
			TRB->TRB_PAIS    := SA2->A2_PAIS
		Else
			RecLock("TRB",.F.)      //Actualizar 
		Endif              
	TRB->(MsUnLock ())
	Next nX
Else   //INGRESOS (SA1)
	For nX := 1 to Len(aSF2ENT)
		For ny := 1 to Len(aSF1SAI)
			nReg := Ascan(aSF1SAI,{|x| x[1] == aSF2ENT[nX][1] })
			If nReg = ny
				aSF2ENT[nX][5] := aSF2ENT[nX][5] - aSF1SAI[ny][6]
			EndIf
		Next ny 
		SA1->(DbSetOrder(1))
		If  SA1->(DbSeek(xFilial("SA1")+aSF2ENT[nX][1]+aSF2ENT[nX][3]))
			//Tomar los datos del proveedor 
			If  SA1->A1_TIPO == "1"  //Es persona Juridica (RAZON SOCIAL) 
				lEsJurid := .T. 
				cRUC     := SA1->A1_CGC  
				cTPPers  := "02"  //Persona Jurica o Entidades
			ElseIf  SA1->A1_TIPO == "2"  //Es persona Natural (NOMBRE)	
				cRUC     := SA1->A1_CGC //SA2->A2_PFISICA
				lEsJurid := .F.    
				cTPPers  := "01"  //Persona Natural
			Else  //Sujeto no domiciliado      
				cTPPers  := "03"  //Sujeto no domiciliado
			Endif                                               				   
		Endif	
		
		If !(TRB->(DbSeek(cRUC)))
			lNotOk := .T.          //Insertar
			RecLock("TRB",.T.)    
			nConsec ++    
			
			TRB->TRB_ITEM    := nConsec
			TRB->TRB_PERIOD  := dAnoEje
			//DECLARANTE					
			TRB->TRB_TPDOCE  := "6"
			TRB->TRB_NODOCE  := SM0->M0_CGC					        
			//DECLARADO   
			TRB->TRB_TPPERO  := cTPPers
			TRB->TRB_TPDOCO  := Alltrim(Str(VAL(SA1->A1_TIPDOC)))
			TRB->TRB_NODOCO  := cRUC
			If  lEsJurid               
				TRB->TRB_RAZON  := SA1->A1_NOME	
			Else
				TRB->TRB_APEPAT := AllTrim(SA1->A1_NOMEPAT) 
				TRB->TRB_APEMAT := AllTrim(SA1->A1_NOMEMAT) 
				TRB->TRB_NOME1  := Alltrim(Substr(SA1->A1_NOMEPES,1,AT(" ",SA1->A1_NOMEPES)))
				TRB->TRB_NOME2  := Alltrim(Substr(SA1->A1_NOMEPES,AT(" ",SA1->A1_NOMEPES),len(SA1->A1_NOMEPES)))
			EndIf
			TRB->TRB_IMPTE	:= aSF2ENT[nX][5]
			TRB->TRB_PAIS    := SA1->A1_PAIS
		Else
			RecLock("TRB",.F.)      //Actualizar 
		Endif              
		TRB->(MsUnLock ())
	Next			
Endif  


//Chamada Relatórios
nUITs := GetMv("MV_UITS",,1)
cFiltroTRB := "TRB_IMPTE > " + lTrim( Str(nUITs) ) + " .And. (TRB_PAIS == '589' .Or. Empty(TRB_PAIS))"
bFiltroTRB := &( "{|| " + cFiltroTRB + " }" )
TRB->(DbSetFilter(bFiltroTRB,cFiltroTRB))

DAOTPEVal()

Return (aTMP)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DAOTPEVal ³Autor  ³Laura Medina        ³Fecha ³ 22/07/2013    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Impresion del reporte para validacion de la generación del    ³±±
±±³          ³archivo psra el DAOT                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³DAOTPE - PERU                                                 ³±±   
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DAOTPEVal()
Local aArea := {}
Local oReport

If MsgYesNo(STR0002+Iif(nRutina==1,"Costos","Ingresos")+STR0018,STR0001)//"¿Desea imprimir el reporte para validacion de la informacion de Costos?" "DAOT"
	aArea := GetArea()
	oReport := TReport():New(STR0001,STR0003,,{|oReport| DAOTImpVal(oReport)},STR0004) //"Reporte de validación de las Informaciones" "Reporte para validación de las informaciones generadas"
	oReport:SetLandscape()
	oReport:SetTotalInLine(.F.)
	oReport:PrintDialog()
	RestArea(aArea)
Endif
Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DAOTImpVal³Autor  ³Laura Medina        ³Fecha ³ 22/07/2013    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Impresion del reporte para validacion de la generación del    ³±±
±±³          ³archivo para el DAOT                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³DAOT - PERU                                                   ³±±   
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DAOTImpVal(oReport) 
Local nConsec := 0

oReport:SetTitle(STR0004 + "  -  " + Alltrim(str(_aTotal[001]))) //"Reporte de las informaciones generadas para DIR" _aTotal[001] = MV_PAR01 (Archivo DAOTPE.ini)
oDetalhe := TRSection():New(oReport,STR0005,)                   //"Reporte de las informaciones generadas para DAOT"
TRCell():New(oDetalhe,"DET_ITEM",,STR0006,,05,.F.)//"No."
TRCell():New(oDetalhe,"DET_TPDOCE",,STR0007,,01,.F.) //Tp Decl  RetTitle("A1_CGC")
TRCell():New(oDetalhe,"DET_NODOCE",,STR0008,,18,.F.) //No Doc Decl
TRCell():New(oDetalhe,"DET_PERIOD",,STR0009,,4,.F.) //Periodo  
TRCell():New(oDetalhe,"DET_TPPERO",,STR0019,,1,.F.) //Tp Pers Decldo
TRCell():New(oDetalhe,"DET_TPDOCO",,STR0010,,2,.F.) //Tp Decldo
TRCell():New(oDetalhe,"DET_NODOCO",,STR0011,,18,.F.) //No Doc Decldo
TRCell():New(oDetalhe,"DET_IMPTE",,STR0012,"@E 9,999,999,999,999",18,.F.)//"Importe"
TRCell():New(oDetalhe,"DET_APEPAT",,STR0013,,20,.F.)  //Ape Paterno
TRCell():New(oDetalhe,"DET_APEMAT",,STR0014,,20,.F.)    //Ape Materno
TRCell():New(oDetalhe,"DET_NOME1",,STR0015,,20,.F.)     //Nombre
TRCell():New(oDetalhe,"DET_NOME2",,STR0016 ,,20,.F.)    //2do Nombre
TRCell():New(oDetalhe,"DET_RAZON",,STR0017,,20,.F.)     //Razon Social


oReport:SetMeter(TRB->(RecCount())+ 1)
oDetalhe:Init()

TRB->(DbGoTop())
While !oReport:Cancel() .And. !TRB->(Eof())      
	nConsec++
	RecLock("TRB",.F.)      //Actualizar  
	TRB->TRB_ITEM    := nConsec
	TRB->(MsUnLock ())
	oDetalhe:Cell("DET_ITEM"):SetValue(alltrim(str(TRB->TRB_ITEM)))
	oDetalhe:Cell("DET_TPDOCE"):SetValue(TRB->TRB_TPDOCE)
	oDetalhe:Cell("DET_NODOCE"):SetValue(TRB->TRB_NODOCE)
	oDetalhe:Cell("DET_PERIOD"):SetValue(TRB->TRB_PERIOD)
	oDetalhe:Cell("DET_TPPERO"):SetValue(TRB->TRB_TPPERO)
	oDetalhe:Cell("DET_TPDOCO"):SetValue(TRB->TRB_TPDOCO)
	oDetalhe:Cell("DET_NODOCO"):SetValue(TRB->TRB_NODOCO)
	oDetalhe:Cell("DET_IMPTE"):SetValue(TRB->TRB_IMPTE)
	oDetalhe:Cell("DET_APEPAT"):SetValue(TRB->TRB_APEPAT)
	oDetalhe:Cell("DET_APEMAT"):SetValue(TRB->TRB_APEMAT)
	oDetalhe:Cell("DET_NOME1"):SetValue(TRB->TRB_NOME1)
	oDetalhe:Cell("DET_NOME2"):SetValue(TRB->TRB_NOME2)
	oDetalhe:Cell("DET_RAZON"):SetValue(TRB->TRB_RAZON)
	oReport:IncMeter()
	oDetalhe:PrintLine()
	TRB->(DbSkip())
Enddo

oReport:SkipLine()
oReport:ThinLine()
oReport:IncMeter()
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DDAOTDel  ³Autor  ³Laura Medina        ³Fecha ³ 22/07/2013    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Borra los archivos temporales procesados.                     ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³DAOTPE - PERU                                                 ³±±   
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DAOTDel(aDelArqs)
Local aAreaDel := GetArea()
Local nI := 0

For nI:= 1 To Len(aDelArqs)
	dbSelectArea(aDelArqs[ni,2])
	dbCloseArea()
Next
If oTmpTableOr <> Nil  
	oTmpTableOr:Delete() 
	oTmpTableOr := Nil 
Endif

RestArea(aAreaDel)
Return
