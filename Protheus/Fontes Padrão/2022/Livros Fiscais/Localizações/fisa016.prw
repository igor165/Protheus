#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"  
#INCLUDE "FISA016.CH"  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FISA016  ³ Autor ³ Felipe V. Nambara       ³ Data ³12/01/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cadastro na tabela CCN                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FISA016                                                      ³±±
±±³            Códigos Industrial Internacional Uniforme                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                     				    	    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOCALIZADO COLOMBIA/EUA                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS     ³  MOTIVO DA ALTERACAO                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Luis Enríquez ³06/12/18³DMINA-1012³Rep. DMINA-253 Se realizan cambios pa-³±±
±±³              ³        ³(EUA)     ³localización, creación de lVldRelSFF()³±±
±±³              ³        ³          ³y se agrega como param. en AxCadastro.³±±
±±³    Marco A.  ³12/06/20³DMINA-9311³Se agrega tratamiento para rutina au- ³±±
±±³              ³        ³          ³matica (TIR) en la funcion CIIUCol.   ³±±
±±³              ³        ³          ³(COL)                                 ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FISA016()
	If cPaisLoc == "COL"
		CIIUCol()
	EndIf
	AxCadastro("CCN",IIf(cPaisLoc == "EUA", STR0008, STR0001),IIf(cPaisLoc == "EUA", "lVldRelSFF()", "IVALIDCCN()"))  //"Registro de Actividad Económica" "Códigos Industrial Internacional Uniforme"
Return()      

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IVALIDCCN ºAutor  ³ Felipe V. Nambara    º Data ³ 12/01/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Valida relacion con tabla CNN y con ello determinar si el    º±±
±±º          ³ registro puede ser eliminado.                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cExp1: Codigo de la Ciudad (CC2_CODMUN)                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Campos CC2_CODMUN (EUA)                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function IVALIDCCN()
	Local llFlag := .T.
	Local alAreaSF4
	Local alAreaSA2
	Local clIndexSF4 := CriaTrab(Nil,.F.)
	Local nlIndexSF4 := 0
	Local clIndexSA2 := CriaTrab(Nil,.F.)
	Local nlIndexSA2 := 0
	               
	alAreaSF4 := SF4->(GetArea())
	alAreaSA2 := SA2->(GetArea())
             
	DbSelectArea("SF4")
	
	IndRegua("SF4",clIndexSF4,"F4_FILIAL+F4_CIIU",,,"")
	
	nlIndexSF4 := RetIndex("SF4")+1		
	
	DbSetOrder(nlIndexSF4)       
	
	DbGoTop()            
	
	If DbSeek(xFilial("SF4")+CCN->CCN_AGCIIU)
		llFlag := .F.
		Aviso(STR0002,STR0004 + SF4->F4_CODIGO,{STR0003}) //"ATENCAO"###"Não é possível excluir esse código de agrupamento, pois o mesmo possui relacionamento com o TES: "###"OK"
	EndIf
	
	FErase(clIndexSF4+OrdBagExt())
		
	If llFlag
		DbSelectArea("SA2")	
		
		IndRegua("SA2",clIndexSA2,"A2_FILIAL+A2_CODICA",,,"")
		
		nlIndexSA2 := RetIndex("SA2")+1		
		
		DbSetOrder(nlIndexSA2)       

		If DbSeek(xFilial("SA2")+CCN->CCN_CIIU)
			llFlag := .F.
			Aviso(STR0002,STR0006 + SA2->A2_NOME + STR0007 + SA2->A2_LOJA,{STR0003}) //"ATENCAO"###"Não é possível excluir esse código de CIIU, pois o mesmo possui relacionamento com o fornecedor: "###"  Loja: "###"OK"
		EndIf
	                                  
		FErase(clIndexSA2+OrdBagExt())
	EndIf         	                  	
		                         
	RestArea(alAreaSF4)
	RestArea(alAreaSA2)	
Return(llFlag)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³lVldRelSFF³ Autor ³ Marco A. Gonzalez R. ³ Data ³ 12/01/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Valida si existe relacion con tabla SFF.                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FISA016 (EUA)                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function lVldRelSFF()
	Local lRet		:= .T.
	Local cQuery	:= ""
	Local nCount	:= 0
	Local cTmpSFF	:= CriaTrab(Nil, .F.)
	Local cFilSFF	:= xFilial("SFF")

	cQuery := "SELECT FF_ZONFIS, FF_COD_TAB"
	CQuery += " FROM " + RetSqlName("SFF") + " SFF"
	cQuery += " WHERE FF_FILIAL	= '" + cFilSFF	+ "'"
	cQuery += " AND FF_ZONFIS = '" + CCN_AGCIIU + "'"
	cQuery += " AND FF_COD_TAB = '" + CCN_CIIU + "'"
	cQuery += " AND D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)   
	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cTmpSFF, .T., .T.)

	Count to nCount 

	(cTmpSFF)->(DBCloseArea())

	If nCount <> 0
		lRet := .F.
		MsgInfo(STR0009, STR0010) //"El registro no puede ser eliminado, ya que se encuentra utilizado en Zonas Fiscales vs Impuestos."  "Registro utilizado"
	EndIf
Return lRet