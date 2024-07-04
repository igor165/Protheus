#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEM051.CH"
#INCLUDE "REPORT.CH"


/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё CambSalM  		ЁAutorЁ  Laura M.         Ё Data Ё21/10/2019Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCambio de salario Minimo (Paraguay)                         Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA030                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  Ёa    														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function GPEM051() //GPEA030CS
Private lActualiz := .F. 
Private dFechaRes := CTOD("//")
Private nPorcent  := 0
Private cSucCamb  := ""
Private cCategor  := ""
Private cTarefas  := ""   
Private lHistori  := .F.
Private cPerg	  := "GPEM051PAR" 
Private nPosCat   := 0
Private nPosDtAj  := 0 
Private nPosVlrU  := 0
Private nPosTare  := 0
Private nPosSMes  := 0
Private nPosSDia  := 0
Private nPosDesc  := 0
Private nPosDAnt  := 0
Private nPosAAnt  := 0
Private aCambSal  := {}
Private aTabS070  := {}
Private aTabS003  := {}
Private cPictSal  := PesqPict("SRJ","RJ_SALARIO",TamSX3("RJ_SALARIO")[1])
Private cPictDia  := PesqPict("SRJ","RJ_VALDIA",TamSX3("RJ_VALDIA")[1]) 
Private cPictFac  := PesqPict("SRJ","RJ_FACCON",TamSX3("RJ_FACCON")[1])  

If  Pergunte(cPerg,.T.)
	If  VldPreg()
		Processa( {|| GerCambSl()}, STR0001,STR0005, .T. ) //STR0001 "Aumento de salario  mМnimo"
		If  Len(aCambSal)>0 .OR. Len(aTabS070)>0 .OR. Len(aTabS003)>0
			GerHisCam()
		Else
			Aviso(STR0003, STR0025 , {STR0002} ) //Atencao, "No existen registros con esos parАmetros.", {OK} 		
		Endif
	Endif
EndIf

Return(.T.)


/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё VldPreg  		ЁAutorЁ  Laura M.         Ё Data Ё21/10/2019Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁValidaciСn del grupo de preguntas (Paraguay)                Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA030                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  Ёa    														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function VldPreg() 
Local lRet  := .T. 

//MakeAdvplExpr(cPerg)


MakeSqlExpr(cPerg)

lActualiz := Iif(MV_PAR01 == 1, .T. , .F. ) //1=Si 2= No
dFechaRes := MV_PAR02
nPorcent  := MV_PAR03
cCategor  := MV_PAR04 
cTarefas  := MV_PAR05   
lHistori  := Iif(MV_PAR06 == 1, .T. , .F. ) //1=Si 2= No

If  Empty(dFechaRes)
	Aviso(STR0003, STR0004 , {STR0002}   ) //Atencao, STR0003 "Indique una Fecha de ResoluciСn" , {OK} 
	lRet  := .F. 
Elseif  nPorcent<= 0
	Aviso(STR0003, STR0006 , {STR0002}   ) //Atencao, STR0003 "Informe un porcentaje de aumento." , {OK} 
	lRet  := .F.
Endif

Return(lRet)

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё GerCambSl  		ЁAutorЁ  Laura M.     Ё Data Ё21/10/2019Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o Ё FunciСn principal para el cambio de salario (Paraguay)     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA030                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  Ёa    														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function GerCambSl() 
Local aArea		:= GetArea()
Local cQuery	:= ""	                         
Local nCont		:= 0
Local nSalAntig := 0
Local nSalTarea := 0 
Local cAliasSRJ := GetNextAlias()
Local nI        := 0
Local nCont     := 0
Local aCabTabA  := {}
Local aCatTare  := {}
Local aCatAnti  := {}
Local lEsDifch  := .F. 

Dbselectarea("RT2")
/*
lActualiz := MV_PAR01
dFechaRes := MV_PAR02
nPorcent  := MV_PAR03
cCategor  := MV_PAR04
cTarefas  := MV_PAR05 
lHistori  := MV_PAR06*/

cQuery := "SELECT RJ_FILIAL, RJ_DESC, RJ_CARGO, RJ_FUNCAO, RJ_SALANT, RJ_SALTAR, RJ_SALARIO, RJ_VALDIA, " 
cQuery += "RJ_FACCON, RJ_DTAJUST, R_E_C_N_O_ SRJRECNO " 
cQuery += "FROM "+RetSqlName("SRJ")+" "					
cQuery += "WHERE "
     
//-- Categorias (SRJ)
If !Empty(cCategor)
	cQuery += cCategor +" AND "
EndIf

cQuery += "D_E_L_E_T_<>'*' AND " 
cQuery += "RJ_FILIAL = '"+xFilial("SRJ")+"' "
cQuery += "ORDER BY RJ_FUNCAO "
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSRJ,.T.,.T.)

Count to nCont
(cAliasSRJ)->(dbGoTop())

       
ProcRegua(nCont) 
While (cAliasSRJ)->(!eof())     
	nI++
	nSalAntig := 0
	nSalTarea := 0
	lEsDifch  := .F. 
   	IncProc(STR0005 + STR0007 + str(nI))
 	If  (cAliasSRJ)->RJ_SALANT == "2"  .And. (cAliasSRJ)->RJ_SALTAR == "2"       	
	   	Begin Transaction
	   	
	   	SRJ->( DbGoto( (cAliasSRJ)->SRJRECNO ) )   		
   		nSalAntig := SRJ->RJ_SALARIO * (1 + ( nPorcent / 100))
   		nSalTarea := SRJ->RJ_VALDIA  * (1 + ( nPorcent / 100))
   	   		
   		If  AnoMes(SRJ->RJ_DTAJUST)!= AnoMes(dFechaRes) //Solo actualiza si el registro no es el mismo que la fecha de ajuste
   		 	lEsDifch  := .T. 
   		 	If  lActualiz
   		 		Reclock("SRJ",.F.)
				SRJ->RJ_SALARIO := nSalAntig  
				SRJ->RJ_VALDIA  := nSalTarea 
				SRJ->RJ_DTAJUST := dFechaRes
				SRJ->( MsUnlock() )
			Endif
		Endif   	   	   	
	   	
	   	If  lHistori  .And.  lActualiz .And. lEsDifch //Solo en este caso se genera historico (NO=No generarМa actualizaciСn)
	   		Dbselectarea("RT2")
	   		RT2->(DbSetOrder(1))
	   		IF  !RT2->(MsSeek((cAliasSRJ)->RJ_FILIAL+(cAliasSRJ)->RJ_FUNCAO+(cAliasSRJ)->RJ_DTAJUST)) 
		   		//Genera historico en la SRJ-Copia 
		   		Reclock("RT2",.T.)
		   		RT2->RT2_FILIAL  := (cAliasSRJ)->RJ_FILIAL
		   		RT2->RT2_FUNCAO  := (cAliasSRJ)->RJ_FUNCAO
		   		RT2->RT2_DESC    := (cAliasSRJ)->RJ_DESC
		   		RT2->RT2_CARGO   := (cAliasSRJ)->RJ_CARGO
		   		RT2->RT2_SALANT  := (cAliasSRJ)->RJ_SALANT
		   		RT2->RT2_SALTAR  := (cAliasSRJ)->RJ_SALTAR
		   		RT2->RT2_FACCON  := (cAliasSRJ)->RJ_FACCON
		   		RT2->RT2_DTAJUS  := STOD((cAliasSRJ)->RJ_DTAJUST)
		   		RT2->RT2_SALARI  := (cAliasSRJ)->RJ_SALARIO  
		   		RT2->RT2_VALDIA  := (cAliasSRJ)->RJ_VALDIA 
		   		RT2->(MsUnlock())
		   	Endif
	   	Endif
	   		   	
	   	aAdd(aCambSal,{(cAliasSRJ)->RJ_FUNCAO,(cAliasSRJ)->RJ_DESC,Iif(!lEsDifch,(cAliasSRJ)->RJ_SALARIO,nSalAntig), Iif(!lEsDifch,(cAliasSRJ)->RJ_VALDIA,nSalTarea), (cAliasSRJ)->RJ_FACCON, "", "", ""})
   		
   		End Transaction
   	Endif  	 	
  	
  	If  (cAliasSRJ)->RJ_SALTAR == "1"  
  		aAdd(aCatTare,(cAliasSRJ)->RJ_FUNCAO )
  	Endif
  	If  (cAliasSRJ)->RJ_SALANT == "1"
  		aAdd(aCatAnti,(cAliasSRJ)->RJ_FUNCAO )
  	Endif

   	(cAliasSRJ)->(dbSkip())	    
EndDo
(cAliasSRJ)->(dbCloseArea()) 
 

//Tratamiento tablas S003 - Salario x Antiguedad y S070 - Salario x Tarea
If  nCont > 0 
	If	Len(aCatTare) > 0   	
	 	aCabTabA := ArmaRCB("S070")
	   	If  Len(aCabTabA)> 0   //S070 - Salario por Tarea
	   		aTabS070:= GeraTabA(aCabTabA,"S070",aCatTare,1)
	   		nCont++
	   	Endif
	Endif
	If  Len(aCatAnti) > 0
		nPosCat  := 0
		nPosDtAj := 0  
		nPosDAnt := 0
		nPosAAnt := 0   
		nPosSMes := 0
		nPosSDia := 0
	   	aCabTabA := ArmaRCB("S003")
	   	If Len(aCabTabA)> 0 //S003 - Salario por Antiguedad
	   	 	aTabS003:= GeraTabA(aCabTabA,"S003",aCatAnti,2)
	   	Endif
	Endif
Else
	Aviso(STR0003, STR0025 , {STR0002} ) //Atencao, "No existen registros con esos parАmetros.", {OK} 
Endif

RestArea(aArea)   
Return(.T.)


/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё ConsHist  		ЁAutorЁ  Laura M.         Ё Data Ё21/10/2019Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁConsulta histСrico  (Paraguay)                         Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA030                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  Ёa    														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function ConsHist()
Local cFiltra			//Variavel para filtro
Local aIndFil	:= {}	//Variavel Para Filtro

Private aRT2Virtual := {}
Private aRT2Visual  := {}
Private aRT2Header  := {}
Private aRT2Fields  := {}
Private aRT2Altera  := {}
Private aRT2NotAlt  := {}
              
Private bFiltraBrw := {|| Nil}		//Variavel para Filtro
Private cCadastro  := OemToAnsi(STR0008) // "Historico de Categorias"
Private aRotina    := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina

Private cBkpFilAnt    := cFilAnt


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicializa o filtro utilizando a funcao FilBrowse                      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
dbSelectArea("RT2")
dbSetOrder(1)

cFiltra 	:= CHKRH(FunName(),"RT2","1")	
bFiltraBrw	:= {|| FilBrowse("RT2",@aIndFil,@cFiltra) }

Eval(bFiltraBrw)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Endereca a funcao de BROWSE                                  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
dbSelectArea("RT2")
dbGoTop()
	
MBrowse(6, 1,22,75,"RT2")
	         
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Deleta o filtro utilizando a funcao FilBrowse                     	   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
EndFilBrw("RT2",aIndFil)
	
cFilAnt := cBkpFilAnt
	
dbSelectArea("RT2")
dbSetOrder(1)

Return


/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё MenuDef		ЁAutorЁ  Laura M.         Ё Data Ё31/10/2019Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁIsola opcoes de menu para que as opcoes da rotina possam    Ё
Ё          Ёser lidas pelas bibliotecas Framework da Versao 9.12 .      Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA030                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/   
Static Function MenuDef()
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Define Array contendo as Rotinas a executar do programa      Ё
	//Ё ----------- Elementos contidos por dimensao ------------     Ё
	//Ё 1. Nome a aparecer no cabecalho                              Ё
	//Ё 2. Nome da Rotina associada                                  Ё
	//Ё 3. Usado pela rotina                                         Ё
	//Ё 4. Tipo de Transa┤└o a ser efetuada                          Ё
	//Ё    1 - Pesquisa e Posiciona em um Banco de Dados             Ё
	//Ё    2 - Simplesmente Mostra os Campos                         Ё
	//Ё    3 - Inclui registros no Bancos de Dados                   Ё
	//Ё    4 - Altera o registro corrente                            Ё
	//Ё    5 - Remove o registro corrente do Banco de Dados          Ё
	//Ё    6 - Alteracao sem inclusao de registro                    Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Local aRotina :=    { 	{ STR0010, "AxVisual"	, 0, 1, NIL, .F.},;	//"Pesquisar"
							{ STR0011, "PesqBrw"	, 0, 2} } 			//"Visualizar"
						  


Return aRotina     


/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё GeraTabA  		ЁAutorЁ  Laura M.         Ё Data Ё21/10/2019Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁModificaciСn de registros y el historico (Paraguay).       Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA030                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  Ёa    														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function GeraTabA(aCabTab,cTab,aCategor,nOpc)
Local nT        := 0
Local nPosIni   := 1
Local nTamCpo   := 0
Local nDecCpo   := 0 
Local aTab_S70  :={}
Local cConteudo := ""
Local cCopyCnt  := ""
Local nCont     := 0 
Local cQuery	:= ""	                       
Local cAliasRCC := GetNextAlias() 
Local aDatosTab := {} 
Local lEsDifch  := .F.  

cQuery := "SELECT RCC_FILIAL, RCC_FIL, RCC_CODIGO, RCC_CHAVE, RCC_CONTEU, R_E_C_N_O_ RCCRECNO " 
cQuery += "FROM "+RetSqlName("RCC")+" "					
cQuery += "WHERE "
cQuery += "D_E_L_E_T_<>'*' " 
cQuery += "AND RCC_FILIAL = '"+xFilial("SRCC")+"' "
cQuery += "AND RCC_CHAVE = ''"
cQuery += "AND RCC_CODIGO = '"+cTab+"' "
  
//-- Tareas solo para tabla (S070)
If  nOpc==1 .And. !Empty(cTarefas)
	If 	AllTrim(Upper(TCGetDB())) $ "MSSQL"
		cQuery += "AND " + Replace(cTarefas,"RCC_CONTEU","SUBSTRING(RCC_CONTEU,1,3)")
	Else
		cQuery += "AND " + Replace(cTarefas,"RCC_CONTEU","SUBSTR(RCC_CONTEU,1,3)")
	Endif  
EndIf
cQuery += "AND ( "
For nT:=1 to len(aCategor)
	If  nT != 1
		cQuery +=  "OR
	Endif
	If  nOpc==1
		If 	AllTrim(Upper(TCGetDB())) $ "MSSQL"
			cQuery +=  " SUBSTRING(RCC_CONTEU,162,5) = '"+aCategor[nT]+"' "
		Else
			cQuery +=  " SUBSTR(RCC_CONTEU,162,5) = '"+aCategor[nT]+"' "
		Endif 
	Elseif  nOpc==2
		If 	AllTrim(Upper(TCGetDB())) $ "MSSQL"
			cQuery +=  " SUBSTRING(RCC_CONTEU,1,5) = '"+aCategor[nT]+"' "
		Else
			cQuery +=  " SUBSTR(RCC_CONTEU,1,5) = '"+aCategor[nT]+"' "
		Endif 
	Endif
Next
cQuery += " )"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasRCC,.T.,.T.)


Count to nCont
(cAliasRCC)->(dbGoTop())

ProcRegua(nCont) 
While (cAliasRCC)->(!EOF()) 
	aTab_S70  := {}
	nPosIni   := 1	
	lEsDifch  := .F. 
	If  Len(aCabTab)>0  

		//Obtener registro por registro de la RCC
		For nT:= 1 To Len(aCabTab) 
                                      
			//--Tamanho do Campo                                          	                
			nTamCpo := aCabTab[nT,3]
			nDecCpo := aCabTab[nT,4]
						
			//--Guarda conteudo do campo na Variavel 				
			If aCabTab[nT,2] == "C" 
				cConteudo := Subs((cAliasRCC)->RCC_CONTEU,nPosIni,nTamCpo)
			ElseIf aCabTab[nT,2] == "N"
				cConteudo := Val(Subs((cAliasRCC)->RCC_CONTEU,nPosIni,nTamCpo+nDecCpo))
			ElseIf aCabTab[nT,2] == "D"
				cConteudo := STOD(Subs((cAliasRCC)->RCC_CONTEU,nPosIni,nTamCpo))
			Endif                   
			//--Posicao Proximo Campo
			nPosIni += nTamCpo		
			Aadd(aTab_S70,cConteudo)
		Next nT	
		
		If  (Iif(nOpc==1,nPosCat>0 .And. nPosDtAj>0 .And. nPosVlrU>0 .And. nPosTare>0 .And. nPosDesc > 0 , ;
			         nPosCat>0 .And. nPosDtAj>0 .And. nPosSMes>0 .And. nPosSDia>0 .And. nPosDAnt>0 .And. nPosAAnt>0)) 

			//Modificar el registro actual                           //Fecha mayor para evitar que los registros sean duplicados.
			If  AnoMes(aTab_S70[nPosDtAj]) != AnoMes(dFechaRes) .And. (dFechaRes>aTab_S70[nPosDtAj]) 
				lEsDifch := .T.
			Endif
			
			//Se va a actualizar y a conservar historico (se inserta registro-historico)
			If  (lActualiz .And. lHistori .And. lEsDifch) 
				InserRCC((cAliasRCC)->RCC_FILIAL, (cAliasRCC)->RCC_CODIGO, (cAliasRCC)->RCC_FIL, (cAliasRCC)->RCC_CONTEU,aTab_S70[nPosDtAj],cTab,;
						aTab_S70[nPosCat],Iif(nOpc==1,aTab_S70[nPosTare],""),Iif(nOpc==2,aTab_S70[nPosDAnt],""),Iif(nOpc==2,aTab_S70[nPosAAnt],""),;
						nOpc)
			Endif
			If  lEsDifch
				aTab_S70[nPosDtAj] := dFechaRes
				If  nOpc == 1
					If  aTab_S70[nPosVlrU]> 0
						aTab_S70[nPosVlrU] := aTab_S70[nPosVlrU] * (1 + ( nPorcent / 100)) 
					Endif
				Elseif nOpc == 2
					If  aTab_S70[nPosSMes]> 0
						aTab_S70[nPosSMes] := aTab_S70[nPosSMes] * (1 + ( nPorcent / 100)) 
					Endif
					If  aTab_S70[nPosSDia]> 0
						aTab_S70[nPosSDia] := aTab_S70[nPosSDia] * (1 + ( nPorcent / 100)) 
					Endif
				Endif
			Endif
			cConteudo := ""
			For nT:= 1 To  Len(aCabTab)	      
			    cCopyCnt  := ""                             			
				If aCabTab[nT,2] == "C"
					cCopyCnt += PADR(aTab_S70[nT],aCabTab[nT,3])
				ElseIf aCabTab[nT,2] == "N"
					If  nOpc == 2 .And. nT==nPosDAnt
						cCopyCnt += Transform(aTab_S70[nPosDAnt],"@E 999.99")
					Elseif nOpc == 2 .And. nT==nPosAAnt
						cCopyCnt += Transform(aTab_S70[nPosAAnt],"@E 999.99") 
					Else
						cCopyCnt += PADL(Alltrim(Str(aTab_S70[nT])),aCabTab[nT,3])
					Endif
				ElseIf aCabTab[nT,2] == "D"
					cCopyCnt += DTOS(aTab_S70[nT])
				Endif
				cConteudo += cCopyCnt           	
			Next nT	
			If  Len(aTab_S70)>0 
				If  nOpc == 1 //S070
					aAdd(aDatosTab,{aTab_S70[nPosCat]+"-"+aTab_S70[nPosTare],aTab_S70[nPosDesc],"","","1", aTab_S70[nPosVlrU],"", ""})
				Elseif nOpc == 2  //S003
					aAdd(aDatosTab,{aTab_S70[nPosCat],POSICIONE("SRJ",1,xFilial("SRJ")+aTab_S70[nPosCat],"RJ_DESC"),aTab_S70[nPosSMes],aTab_S70[nPosSDia],"30","",aTab_S70[nPosDAnt],aTab_S70[nPosAAnt]})
				Endif
			
				If  lActualiz .And. lEsDifch
					RCC->(DbGoto((cAliasRCC)->RCCRECNO ))
					Reclock("RCC",.F.)
					RCC_CONTEU := cConteudo
					RCC->( MsUnlock() )
					
				Endif
			Endif
			
		Endif	  
	Endif
			
(cAliasRCC)->(dbSkip())	
Enddo

Return aDatosTab



/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё ArmaRCB  		ЁAutorЁ  Laura M.         Ё Data Ё21/10/2019Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁArma encabezado RCB  (Paraguay)                             Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA030                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  Ёa    														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function ArmaRCB(cTab)
Local aCabTab      := {}


dbSelectArea("RCB")
RCB->(Dbsetorder(1))

If  dbSeek(Xfilial("RCB")+cTab,.T.)
	While ! Eof() .And.  RCB->RCB_CODIGO == cTab	
		//--Carrega o Cabecalho da Tabela 
		RCB->(Aadd(aCabTab,{RCB_CAMPOS,RCB_TIPO,RCB_TAMAN,RCB_DECIMA}))
		RCB->(dbSkip())
	Enddo	
Endif

nPosCat  := aScan(aCabTab,{ |x| UPPER(Alltrim(x[1])) = "CATEGORIA" })
nPosDtAj := aScan(aCabTab,{ |x| UPPER(Alltrim(x[1])) = "FCHAJUSTE" })  
nPosCodT := aScan(aCabTab,{ |x| UPPER(Alltrim(x[1])) = "CODIGO" })
nPosVlrU := aScan(aCabTab,{ |x| UPPER(Alltrim(x[1])) = "VALUNITAR" })
nPosTare := aScan(aCabTab,{ |x| UPPER(Alltrim(x[1])) = "CODIGO" })   
nPosSMes := aScan(aCabTab,{ |x| UPPER(Alltrim(x[1])) = "SALMES" })
nPosSDia := aScan(aCabTab,{ |x| UPPER(Alltrim(x[1])) = "SALDIA" })
nPosDesc := aScan(aCabTab,{ |x| UPPER(Alltrim(x[1])) = "DESCRIP" })  
nPosDAnt := aScan(aCabTab,{ |x| UPPER(Alltrim(x[1])) = "DEANT" })
nPosAAnt := aScan(aCabTab,{ |x| UPPER(Alltrim(x[1])) = "AANT" })      
   
Return aCabTab


/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё InserRCC  		ЁAutorЁ  Laura M.         Ё Data Ё21/10/2019Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁInserta registro cuando: Genera Historico? = Si  (Paraguay) Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA030                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  Ёa    														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function InserRCC(cRCCFil,cCodigo,cFilRCC,cConten,dDataRef,cTab,cCatAlf,cTarAlf,nDAnt,nAAnt,nOpc)
Local aAreaRCC  := RCC->(GetArea())
Local cMesAno   := AnoMes(dDataRef)  
Local nCont     := 0 
Local cQuery	:= ""	             
          
Local cAliasRCC := GetNextAlias() 
Local cSequen   := '001'

cQuery := "SELECT RCC_FILIAL, RCC_FIL, RCC_CODIGO, RCC_CHAVE, RCC_CONTEU, R_E_C_N_O_ RCCRECNO " 
cQuery += "FROM "+RetSqlName("RCC")+" "					
cQuery += "WHERE "
cQuery += "D_E_L_E_T_<>'*' " 
cQuery += "AND RCC_FILIAL = '"+xFilial("SRCC")+"' "
cQuery += "AND RCC_CODIGO = '"+cTab+"' "
cQuery += "AND RCC_FIL    = '"+cFilRCC+"' "
cQuery += "AND RCC_CHAVE  = '"+cMesAno+"' "

  //-- Tareas solo para tabla (S070)
If  nOpc==1 .And. !Empty(cTarAlf)
	If 	AllTrim(Upper(TCGetDB())) $ "MSSQL"
		cQuery += "AND SUBSTRING(RCC_CONTEU,1,3) = '"+cTarAlf+"' "
	Else
		cQuery += "AND SUBSTR(RCC_CONTEU,1,3) = '"+cTarAlf+"' "
	Endif  
EndIf
cQuery += "AND ( "
	If  nOpc==1
		If 	AllTrim(Upper(TCGetDB())) $ "MSSQL"
			cQuery +=  " SUBSTRING(RCC_CONTEU,162,5) = '"+cCatAlf+"' "
		Else
			cQuery +=  " SUBSTR(RCC_CONTEU,162,5) = '"+cCatAlf+"' "
		Endif 
	Elseif  nOpc==2
		If 	AllTrim(Upper(TCGetDB())) $ "MSSQL"
			cQuery +=  " SUBSTRING(RCC_CONTEU,1,5) = '"+cCatAlf+"' AND "
			cQuery +=  " SUBSTRING(RCC_CONTEU,126,6) = '"+Transform(nDAnt,"@E 999.99")+"' AND "
			cQuery +=  " SUBSTRING(RCC_CONTEU,132,6) = '"+Transform(nAAnt,"@E 999.99")+"' "
		Else
			cQuery +=  " SUBSTR(RCC_CONTEU,1,5) = '"+cCatAlf+"' AND "
			cQuery +=  " SUBSTR(RCC_CONTEU,126,6) = '"+Transform(nDAnt,"@E 999.99")+"' AND "
			cQuery +=  " SUBSTR(RCC_CONTEU,132,6) = '"+Transform(nAAnt,"@E 999.99")+"' "
		Endif 
	Endif
cQuery += " )"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasRCC,.T.,.T.)

Count to nCont
(cAliasRCC)->(dbGoTop())

If  nCont == 0
	cSequen := ObtSec(cTab,cFilRCC,cMesAno)
	Dbselectarea("RCC")
	RCC->( DBAppend() )
	RCC_FILIAL := cRCCFil
	RCC_CODIGO := cCodigo
	RCC_FIL    := cFilRCC
	RCC_CHAVE  := cMesAno
	RCC_SEQUEN := cSequen 
	RCC_CONTEU := cConten
	RCC->( DBCommit() ) 
Endif

RCC->(RestArea(aAreaRCC))
Return 


/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё GerHisCam  	ЁAutorЁ  Laura M.         Ё Data Ё31/10/2019Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁInforme con los cambios.                                   Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA030                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  Ёa    														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function GerHisCam()
Local aArea    := GetArea()
Local oReport  := Nil
Local aReport  := {}
Local nloop    := 0
Private cPerg2    := "GPEM051PA2"
Private nTamValor := TamSX3("RD_VALOR")[1]
Private cPictVlr  := PesqPict("SRC", "RC_VALOR", TamSX3("RC_VALOR")[1])
Private nOpcRep   := 0

//Len(aCambSal)>0 .OR. Len(aTabS070)>0 .OR. Len(aTabS003)>0

If  Pergunte(cPerg2,.T.)

	//MV_PAR01 - ©Reporte a Generar? 
	
	nOpcRep   := MV_PAR01 //1-Categorias, 2-Tareas, 3 - Salario mМnimo por antiguedad 4- Todos  
	If  nOpcRep == 1
		aReport := aCambSal
	ElseIf nOpcRep == 2
		aReport := aTabS070
	ElseIf nOpcRep == 3
		aReport := aTabS003
	Else
		If  Len(aCambSal)>0 
			For nLoop:= 1 to Len(aCambSal)
				Aadd(aReport,aCambSal[nLoop])
			Next nLoop
		Endif 
		If  Len(aTabS070)>0
			//nPosCat>0 .And. nPosDtAj>0 .And. nPosVlrU>0 .And. nPosTare>0
			For nLoop:= 1 to Len(aTabS070)
				Aadd(aReport,aTabS070[nLoop])
			Next nLoop
		Endif
		If  Len(aTabS003)>0
			//nPosCat>0 .And. nPosDtAj>0 .And. nPosVlrU>0 .And. nPosTare>0
			For nLoop:= 1 to Len(aTabS003)
				Aadd(aReport,aTabS003[nLoop])
			Next nLoop
		Endif
	Endif
	
	oReport := ReportDef(nOpcRep, aReport)
	oReport:PrintDialog()
	RestArea(aArea)

Endif
Return


/*
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммямммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁReportDef  ╨Autor  ЁLuis Samaniego      ╨Fecha Ё  10/11/16   ╨╠╠
╠╠лммммммммммьмммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё Define reporte                                              ╨╠╠
╠╠╨          Ё                                                             ╨╠╠
╠╠лммммммммммьммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё SIGAGPE                                                     ╨╠╠
╠╠хммммммммммоммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Static Function ReportDef(nOpcRep,aReport)
Local oReport
Local oSectionA
Local oSectionB
Local cNomeProg := FunName()
Local cTitulo   := STR0012

//ALTERA O TITULO DO RELATORIO
//oReport:SetTitle(cTitulo)
DEFINE REPORT oReport NAME cNomeProg TITLE cTitulo PARAMETER ""/*cPerg2*/ ACTION {|oReport| PrintReport(oReport,oSectionA,oSectionB,nOpcRep,aReport) } DESCRIPTION STR0012 //"Reporte de Aumento de Salario MМnimo"
oReport:SetTotalInLine(.T.)
oReport:SetLandscape(.T.)
oReport:lHeaderVisible := .T. 	

//DEFINE O TOTAL DA REGUA DA TELA DE PROCESSAMENTO DO RELATORIO
oReport:SetMeter(LastRec())        

DEFINE SECTION oSectionA OF oReport TITLE OemToAnsi(STR0012) TABLES "SRJ","RCC" //STR0012 "Reporte de Aumento de Salario MМnimo"
	DEFINE CELL NAME "FECHARES" OF oSectionA TITLE (OemToAnsi(STR0024)+ ': '+DTOC(dFechaRes)+space(50)+OemToAnsi(STR0013)+': '+Alltrim(str(nPorcent))) SIZE 200 HEADER ALIGN LEFT
	oSectionA:SetTotalInLine(.F.)
	oSectionA:SetHeaderSection(.F.)
	
DEFINE SECTION oSectionB OF oReport TITLE OemToAnsi(STR0012) TABLES "SRJ","RCC" //STR0012 "Reporte de Aumento de Salario MМnimo"
/*01*/DEFINE CELL NAME "CODIGO"  	OF oSectionB TITLE OemToAnsi(STR0014) SIZE TamSX3("RJ_FUNCAO")[1]+10  HEADER ALIGN LEFT 	
/*02*/DEFINE CELL NAME "DESCRIP" 	OF oSectionB TITLE OemToAnsi(STR0015) SIZE 100 HEADER ALIGN LEFT
/*03*/DEFINE CELL NAME "SALARIOM" 	OF oSectionB TITLE OemToAnsi(STR0016+STR0017) SIZE TamSX3("RJ_VALDIA")[1]+20 HEADER ALIGN LEFT
/*04*/DEFINE CELL NAME "SALARIOD" 	OF oSectionB TITLE OemToAnsi(STR0016+STR0018) SIZE TamSX3("RJ_VALDIA")[1]+20 HEADER ALIGN LEFT
/*05*/DEFINE CELL NAME "FACTOR"     OF oSectionB TITLE OemToAnsi(STR0019) SIZE TamSX3("RJ_FACCON")[1]+10 HEADER ALIGN LEFT
/*06*/DEFINE CELL NAME "SALARIOT" 	OF oSectionB TITLE OemToAnsi(STR0016+STR0020) SIZE TamSX3("RJ_VALDIA")[1]+20 HEADER ALIGN LEFT
/*07*/DEFINE CELL NAME "DEANTIGU" 	OF oSectionB TITLE OemToAnsi(STR0021+STR0023) SIZE 20 HEADER ALIGN LEFT
/*08*/DEFINE CELL NAME "AANTIGUE" 	OF oSectionB TITLE OemToAnsi(STR0022+STR0023) SIZE 20 HEADER ALIGN LEFT
	
oSectionB:SetHeaderPage(.F.)
oSectionB:SetHeaderSection(.F.) 
oSectionB:SetHeaderBreak(.F.)			
Return oReport


/*
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммямммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPrintReport╨Autor  ЁLaura Medina        ╨Fecha Ё  10/11/16   ╨╠╠
╠╠лммммммммммьмммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё Define reporte                                              ╨╠╠
╠╠╨          Ё                                                             ╨╠╠
╠╠лммммммммммьммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё SIGAGPE                                                     ╨╠╠
╠╠хммммммммммоммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Static Function PrintReport(oReport,oSectionA,oSectionB,nOpcRep,aReport)
Local nLoop     := 0

If Len(aReport) > 0
	oReport:StartPage()
	oReport:SetPageNumber(1)
	
	oSectionA:Init()
	oSectionA:Cell("FECHARES"):SetTitle("")
	oSectionA:Cell("FECHARES"):SetValue((OemToAnsi(STR0024)+ ': '+DTOC(dFechaRes)+space(50)+OemToAnsi(STR0013)+': '+Alltrim(str(nPorcent)) ))
	oSectionA:PrintLine()
	oReport:ThinLine()
	
	oSectionB:Init()
	oSectionB:Cell("CODIGO"):SetTitle("")
	oSectionB:Cell("DESCRIP"):SetTitle("")
	oSectionB:Cell("SALARIOM"):SetTitle("")
	oSectionB:Cell("SALARIOD"):SetTitle("")
	oSectionB:Cell("FACTOR"):SetTitle("")
	oSectionB:Cell("SALARIOT"):SetTitle("")
	oSectionB:Cell("DEANTIGU"):SetTitle("")
	oSectionB:Cell("AANTIGUE"):SetTitle("")
	
	oSectionB:Cell("CODIGO"):SetValue(OemToAnsi(STR0014))
	oSectionB:Cell("DESCRIP"):SetValue(OemToAnsi(STR0015))
	oSectionB:Cell("SALARIOM"):SetValue(OemToAnsi(STR0016+STR0017))
	oSectionB:Cell("SALARIOD"):SetValue(OemToAnsi(STR0016+STR0018))
	oSectionB:Cell("FACTOR"):SetValue(OemToAnsi(STR0019))
	oSectionB:Cell("SALARIOT"):SetValue(OemToAnsi(STR0016+STR0020))
	oSectionB:Cell("DEANTIGU"):SetValue(OemToAnsi(STR0021+STR0023))
	oSectionB:Cell("AANTIGUE"):SetValue(OemToAnsi(STR0022+STR0023))
	oSectionB:PrintLine()
	//oReport:SkipLine(1)
	oReport:ThinLine()	
Endif 
	

For  nLoop:=1 to Len(aReport)
	If  oReport:Cancel()
		Exit
	EndIf //cPictSal cPictDia
	oSectionB:Cell("CODIGO"):SetValue(aReport[nLoop,1])
	oSectionB:Cell("DESCRIP"):SetValue(aReport[nLoop,2]) 
	oSectionB:Cell("SALARIOM"):SetValue(Transform(aReport[nLoop,3],cPictDia))
	oSectionB:Cell("SALARIOD"):SetValue(Transform(aReport[nLoop,4],cPictDia))
	oSectionB:Cell("FACTOR"):SetValue(Transform(aReport[nLoop,5],cPictFac))		
	oSectionB:Cell("SALARIOT"):SetValue(Transform(aReport[nLoop,6],cPictDia))
	oSectionB:Cell("DEANTIGU"):SetValue(Transform(aReport[nLoop,7],"@E 999.99"))
	oSectionB:Cell("AANTIGUE"):SetValue(Transform(aReport[nLoop,8],"@E 999.99"))
	oSectionB:PrintLine()
Next 
oReport:ThinLine()

oReport:EndPage()//Finaliza reporte
oReport:EndReport()

Return


/*
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммямммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁObtSec     ╨Autor  ЁLaura Medina        ╨Fecha Ё  28/11/16   ╨╠╠
╠╠лммммммммммьмммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё Obtener el consecutivo de secuencia.                        ╨╠╠
╠╠╨          Ё                                                             ╨╠╠
╠╠лммммммммммьммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё SIGAGPE                                                     ╨╠╠
╠╠хммммммммммоммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Static Function ObtSec(cTab,cFilRCC,cMesAno) 
Local cSeq := TamSX3("RCC_SEQUEN")[1]
Local aAreaRCC  := RCC->(GetArea())
Local cQuery	:= ""	                 
Local cAliasRCC := GetNextAlias() 
Local nCont     := 0

cQuery := "SELECT COUNT(RCC_SEQUEN) AS SEQUENC" 
cQuery += "FROM "+RetSqlName("RCC")+" "					
cQuery += "WHERE "
cQuery += "D_E_L_E_T_<>'*' " 
cQuery += "AND RCC_FILIAL = '"+xFilial("SRC")+"' "
cQuery += "AND RCC_CODIGO = '"+cTab+"' "
cQuery += "AND RCC_FIL    = '"+cFilRCC+"' "
cQuery += "AND RCC_CHAVE  = '"+cMesAno+"' "
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasRCC,.T.,.T.)

Count to nCont

(cAliasRCC)->(dbGoTop())

If  nCont > 0
	cSeq := STRZERO(((cAliasRCC)->SEQUENC + 1) , cSeq)
Else
	cSeq := "001"
Endif

Return cSeq

