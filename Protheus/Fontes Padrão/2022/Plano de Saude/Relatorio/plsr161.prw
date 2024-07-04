#INCLUDE "PLSR161.CH"
#IFDEF TOP
	#INCLUDE "TOPCONN.CH"
#ENDIF

Static objCENFUNLGP := CENFUNLGP():New()
/*
BF1	- Opcionais do Contrato
BF4 - Opcionais do Usuario
*/

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSR161 ³ Autor ³ Natie Sugahara         ³ Data ³ 03/07/03 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Usuarios por Opcional                                      ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Sintaxe   ³ PLSR161()                                                  ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Uso      ³ Advanced Protheus                                          ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Alteracoes desde sua construcao inicial                               ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Data     ³ BOPS ³ Programador ³ Breve Descricao                       ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³          |      |             |                                       ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                                
Function PLSR161()
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Define variaveis padroes para todos os relatorios...                     ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
PRIVATE wnRel
PRIVATE cNomeProg   := "PLSR161"
PRIVATE nLimite     := 80
PRIVATE nTamanho    := "P"
PRIVATE Titulo		:= oEmToAnsi(STR0001)
PRIVATE cDesc1      := oEmToAnsi(STR0001)
PRIVATE cDesc2      := ""
PRIVATE cDesc3      := ""
PRIVATE cAlias      := "BF1"
PRIVATE cPerg       := "PLR161"
PRIVATE Li         	:= 0
PRIVATE m_pag       := 1
PRIVATE lCompres    := .F.
PRIVATE lDicion     := .F.
PRIVATE lFiltro     := .T.
PRIVATE lCrystal    := .F.
PRIVATE aReturn     := { oEmToAnsi(STR0002), 1,oEmToAnsi(STR0003) , 1, 1, 1, "",1 }
PRIVATE aOrd		:= { STR0004}												//--Cod.Int+Cod.Emp+Matricula
PRIVATE lAbortPrint := .F.
PRIVATE cCabec1     := ""
PRIVATE cCabec2     := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Utilizadas na funcao IMPR                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCabec
PRIVATE Colunas		:= 080
PRIVATE AT_PRG  	:= "PLSR161"
PRIVATE wCabec0 	:= 2
PRIVATE wCabec1		:= space(3) + oemtoAnsi(STR0009)					//-- Cabecalho do Detalhe
PRIVATE wCabec2		:= space(3) + oemtoAnsi(STR0010)					//-- Cabecalho do Dependente 
PRIVATE wCabec3		:=""
PRIVATE wCabec4		:=""
PRIVATE wCabec5		:=""
PRIVATE wCabec6		:=""
PRIVATE wCabec7		:=""
PRIVATE wCabec8		:=""
PRIVATE wCabec9		:=""
PRIVATE CONTFL		:=1
PRIVATE cPathPict	:= ""

Pergunte(cPerg,.F.)

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Envia controle para a funcao SETPRINT                        ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
wnrel:="Plsr161"					           //Nome Default do relatorio em Disco
wnrel:=SetPrint(cAlias,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,nTamanho,,.f.)

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  | Verifica se foi cancelada a operacao                                     ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If nLastKey  == 27
   Return
Endif
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Configura impressora                                                     ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
SetDefault(aReturn,cAlias)

If nLastKey = 27
	Return
Endif 

aAlias := {"BF1", "BA0", "BI3", "BA1", "BRP", "BA0"}
objCENFUNLGP:setAlias(aAlias)

MsAguarde({|lEnd| R161Imp(@lEnd,wnRel,cAlias)}, Titulo, "", .T.) // Exibe dialogo padrao ...

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ R161Imp  ³ Autor ³ Natie Sugahara        ³ Data ³ 03/07/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Emite relatorio                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/
Static Function R161Imp()
Local   cPict			:= "@E 999,999,999"
Local	cOperad  		:= ""
Local	cGrupEmp 		:= ""
Local	cOpcional 		:= ""
Local   cDataNasc		:= ""
Local 	cDet			:= ""
Local   nTotOpeTit 		:= 0
Local   nTotOpeDep		:= 0
Local   nTitEmp 		:= 0
Local   nDepEmp			:= 0
Local   nTitular		:= 0
Local   nDependente		:= 0
Local   nTotDepende		:= 0
Local   nTotTitular		:= 0
Local   dDatBas         := IIf(ValType("MV_PAR14")=='D', IIf(!Empty(MV_PAR14), MV_PAR14, dDataBase) , dDataBase )
Local   cMvPLCDTGP      := GETMV("MV_PLCDTGP") 

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Acessa parametros do relatorio...                                        ³
  ³ Variaveis utilizadas para parametros                                     ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
nTipPes    := mv_par01 							//-- Tipo de Contrato	 [1-Pessoa Fisica 2- Pessoa Juridica 3-Ambos]
nAtivo     := mv_par02                          //-- Considera Registros [1-Ativo 2- Bloqueados]
cOpeDe     := mv_par03 							//-- Operadora De
cOpeAte    := mv_par04 							//-- Operadora ATe
cGrupoDe   := mv_par05 							//-- Grupo/Empresa De 
cGrupoAte  := mv_par06 							//-- Grupo/Empresa Ate
cContrDe   := mv_par07 							//-- Contrato De
cContrAte  := mv_par08 							//-- Contrato Ate
cSbConDe   := mv_par09							//-- Sub-Contrato De
cSbConAte  := mv_par10 							//-- Sub-Contrato Ate
cOpcioDe   := mv_par11							//-- Opcional De
cOpcioAte  := mv_par12							//-- Opcional Ate
nDepende   := mv_par13							//-- Relaciona Dependete  1-SIM       2-NAO

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Faz filtro no arquivo...                                                 ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
#IFDEF TOP
	    cSQL := "SELECT BF1.BF1_FILIAL , BF1.BF1_CODINT, BF1.BF1_CODEMP, BF1.BF1_CODPRO, BF1.BF1_MATRIC, BF1.BF1_MOTBLO,"
	    cSQL += "BA1.BA1_CONEMP, BA1.BA1_SUBCON, BA1.BA1_TIPREG, BA1.BA1_DIGITO, BA1.BA1_DATNAS, BA1.BA1_NOMUSR, BA1.BA1_SEXO, BA1.BA1_GRAUPA "
	    cSQL += "FROM "+RetSQLName("BF1")+" BF1, " +RetSQLName("BA1")+" BA1 "
	    cSQL += "WHERE "
        cSQL += "BF1.D_E_L_E_T_ = ' '  AND "
        cSQL += "BA1.D_E_L_E_T_ = ' '  AND "
        cSQL += "BF1.BF1_FILIAL = '"+xFilial("BF1")+"' AND "
        cSQL += "BA1.BA1_FILIAL = '"+xFilial("BA1")+"' AND "
        cSQL += "BF1.BF1_CODINT = BA1.BA1_CODINT  AND "
        cSQL += "BF1.BF1_CODEMP = BA1.BA1_CODEMP  AND "
        cSQL += "BF1.BF1_MATRIC = BA1.BA1_MATRIC  AND "
		cSQL += "BF1.BF1_CODINT >= '"+cOpeDe   +"' AND "
		cSQL += "BF1.BF1_CODINT <= '"+cOpeAte  +"' AND "
		cSQL += "BF1.BF1_CODEMP >= '"+cGrupoDe +"' AND "
		cSQL += "BF1.BF1_CODEMP <= '"+cGrupoAte+"' AND "
		cSQL += "BF1.BF1_CODPRO >= '"+cOpcioDe +"' AND "
		cSQL += "BF1.BF1_CODPRO <= '"+cOpcioAte+"' "
		

		If nTipPes == 2 								// Pessoa Juridica
			cSQL += " AND BA1.BA1_CONEMP >= '"+cContrDe +"' "
			cSQL += " AND BA1.BA1_CONEMP <= '"+cContrAte+"' " 
			cSQL += " AND BA1.BA1_SUBCON >= '"+cSbConDe +"' " 
			cSQL += " AND BA1.BA1_SUBCON <= '"+cSbConAte+"' "
			cSQL += " AND BA1.BA1_CONEMP <> ''  "
			cSQL += " AND BA1.BA1_SUBCON <> ''  "
		Elseif nTipPes == 1 							// Pessoa Fisica
			cSQL += " AND BA1.BA1_CONEMP = ''   "
			cSQL += " AND BA1.BA1_SUBCON = ''   "
		Endif

		cSQL += "	AND BA1_DATINC <='"+DTOS(dDatBas)+"' "
		cSQL += "	AND BF1_DATBAS <='"+DTOS(dDatBas)+"' "

		If  nAtivo == 1 //Ativo
			cSQL += "AND (BA1_DATBLO = '   ' OR BA1_DATBLO >'"+DTOS(dDatBas)+"') "
			cSQL += "AND (BF1_DATBLO = '   ' OR BF1_DATBLO >'"+DTOS(dDatBas)+"') "

		ElseIf nAtivo == 2 //Bloqueado      
			cSQL += "AND ( (BA1_DATBLO <> '   ' AND BA1_DATBLO <='"+DTOS(dDatBas)+"') "
			cSQL += "OR  (BF1_DATBLO <> '   ' AND BF1_DATBLO <='"+DTOS(dDatBas)+"') ) "

		EndIf

        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Se houver filtro executa parse para converter expressoes adv para SQL    ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        If ! Empty(aReturn[7])
			cSQL += " and " + PLSParSQL(aReturn[7])
        Endif
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Define order by de acordo com a ordem...                                 ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
		cSQL += "ORDER BY BF1.BF1_FILIAL + BF1.BF1_CODINT + BF1.BF1_CODEMP + BF1.BF1_CODPRO  + BF1.BF1_MATRIC + BA1.BA1_TIPREG "
		cSQL := PLSAvaSQL(cSQL)
        TCQUERY cSQL NEW ALIAS "BF1Trb"
#ENDIF

BF1Trb->( dbgoTop() )
Li 	:= 0
While !(BF1Trb->( Eof() ))

	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  ³ Impressao do Detalhe                                               ³
	  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	Impr("","C",,,03,.T.,.T.)
	Impr( oEmToansi(STR0006) +  objCENFUNLGP:verCamNPR("BF1_CODINT", BF1Trb->BF1_CODINT) + space(1)+ objCENFUNLGP:verCamNPR("BA0_NOMINT", fDesc("BA0", BF1Trb->BF1_CODINT,"BA0_NOMINT" )) ,"C",,,03,.T.)
    cOperad  := BF1TRB->BF1_CODINT
	While !(BF1Trb->(Eof())) .And. BF1TRB->BF1_CODINT == cOperad
		
		Impr( oEmToAnsi(STR0008) +  objCENFUNLGP:verCamNPR("BF1_CODEMP", BF1Trb->BF1_CODEMP)	, "C",,,03,.T.)
	
		/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		  | Atribuo valor as variaveis de controle...                                ³
	      ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	    cOperad  := BF1Trb->BF1_CODINT
	    cGrupEmp := BF1Trb->BF1_CODEMP
		While !(BF1Trb->(Eof()) ) .And. BF1Trb->(BF1_CODINT+BF1_CODEMP) == cOperad+cGrupEmp
			/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			  ³ Total Por Opcionais                                                ³
			  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			Impr("","C")
			Impr( oEmToAnsi(STR0011)+  objCENFUNLGP:verCamNPR("BF1_CODPRO", BF1Trb->BF1_CODPRO) + SPACE(1) + objCENFUNLGP:verCamNPR("BI3_DESCRI", fDesc("BI3",  BF1Trb->(BF1_CODINT + BF1_CODPRO) , "BI3_DESCRI")) , "C",,,03,.T.)
			Impr( __PrtThinLine(),"C")
			cOperad  	:= BF1TRB->BF1_CODINT
			cGrupEmp 	:= BF1TRB->BF1_CODEMP
			cOpcional 	:= BF1TRB->BF1_CODPRO
			While !(BF1TRB->(Eof()) ) .And. BF1TRB->(BF1_CODINT+BF1_CODEMP+BF1_CODPRO ) == cOperad+cGrupEmp+cOpcional
				cOperad  	:= BF1TRB->BF1_CODINT
				cGrupEmp 	:= BF1TRB->BF1_CODEMP
				cOpcional 	:= BF1TRB->BF1_CODPRO
				cMatric		:= BF1Trb->BF1_MATRIC
				While !(BF1TRB->(Eof()) ) .And. BF1Trb->(BF1_CODINT+BF1_CODEMP+BF1_CODPRO+BF1_MATRIC ) == cOperad+cGrupEmp+cOpcional + cMatric
			      /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   	 		    ³ Exibe mensagem...                                                  ³
					ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			      	MsProcTXT("Imprimindo " + objCENFUNLGP:verCamNPR("BF1_CODINT", BF1Trb->BF1_CODINT) + "." + objCENFUNLGP:verCamNPR("BF1_CODEMP", BF1Trb->BF1_CODEMP) + "." + objCENFUNLGP:verCamNPR("BF1_MATRIC", BF1Trb->BF1_MATRIC) + "..." )
					/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					  ³ Verifica se foi abortada a impressao...                            ³
					  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
					If Interrupcao(lAbortPrint)
						Exit
					Endif

					If BF1Trb->BA1_TIPREG == cMvPLCDTGP																						//-- Titular
						cDataNasc	:= BF1Trb->(SUBSTRING(BA1_DATNAS,7,2)+'/'+SUBSTRING(BA1_DATNAS,5,2)+'/'+SUBSTRING(BA1_DATNAS,1,4) )
						cDet		:= objCENFUNLGP:verCamNPR("BF1_MATRIC", BF1Trb->BF1_MATRIC) + space(1) + left(objCENFUNLGP:verCamNPR("BA1_NOMUSR", BF1Trb->BA1_NOMUSR),35) +space(1)   							//-- Matricula + Nome Usuario 
						cDet		+= objCENFUNLGP:verCamNPR("BA1_DATNAS", cDataNasc)  + space(2)+ objCENFUNLGP:verCamNPR("BA1_DATNAS", Transform( Calc_idade( dDataBase,ctod(cDataNasc)),"@E 999"))+space(3)		//--  Data Nascto
						cDet		+= If(BF1Trb->BA1_SEXO="1",  objCENFUNLGP:verCamNPR("BA1_SEXO", oEmToAnsi(STR0013)), objCENFUNLGP:verCamNPR("BA1_SEXO", oEmToAnsi(STR0014)))								//-- Sexo
						Impr(cDet,"C",,,03,.T.)
						/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						  ³ Totalizadores                                                      ³
						  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
						nTitular 	++
						nTitEmp 	++
						nTotOpeTit  ++
						nTotTitular	++
					Else
						If nDepende == 1																														//-- Relaciona Dependente
							cDet	:= objCENFUNLGP:verCamNPR("BA1_NOMUSR", left(BF1Trb->BA1_NOMUSR,35)) + Space(1) + objCENFUNLGP:verCamNPR("BA1_GRAUPAR", BF1Trb->BA1_GRAUPAR) + Space(1) + objCENFUNLGP:verCamNPR("BRP_DESCRI", fDesc("BRP",	BF1Trb->BA1_GRAUPAR,"BRP_DESCRI")) 	//-- Nome Dependente + Grau de Parentesco
							Impr(cDet,"C",,,10,.T.)
 						Endif         
						/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						  ³ Totalizadores                                                      ³
						  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
 						nDependente ++
						nDepEmp		++
						nTotOpeDep  ++ 
						nTotDepende ++
					Endif
					BF1Trb->( DbSkip() )
				Enddo
			Enddo
			/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			  ³ Total Por Opcional                                                 ³
			  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			Impr(""                 ,"C")
			Impr( __PrtThinLine()   ,"C")
			Impr(oEmToAnsi(STR0015) ,"C",,,03,.T. )
			Impr( __PrtThinLine()   ,"C")
			cDet	:= objCENFUNLGP:verCamNPR("BF1_CODINT", cOperad)+objCENFUNLGP:verCamNPR("BF1_CODPRO", cOpcional) + SPACE(1) + objCENFUNLGP:verCamNPR("BI3_DESCRI", LEFT(fDesc("BI3", cOperad+cOpcional , "BI3_DESCRI"),30)) + Space(1)
			cDet	+= Transform(nTitular,cPict)                 + Space(1)
			cDet	+= Transform(nDependente,cPict)              + Space(1)
			cDet	+= Transform( ( nDependente + nTitular ),cPict )
			Impr( cDet , "C",,,03,.T.)
			nTitular 	:= 0
			nDependente	:= 0
		Enddo
		/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		  ³ Total Por Grupo / empresa                                          ³
		  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		If nTitEmp	> 0 .or. nDepEmp > 0 
			Impr("","C")
			cDet	:= oEmToAnsi(STR0007)  + Transform(objCENFUNLGP:verCamNPR("BF1_CODINT", cOperad),"@R #.###")+"."+ objCENFUNLGP:verCamNPR("BF1_CODEMP", cGrupEmp) + space(3)
			cDet	+= Transform(nTitEmp,cPict)                 + Space(1)
			cDet	+= Transform(nDepEmp,cPict)                 + Space(1)
			cDet	+= Transform( (nTitEmp + nDepEmp),cPict )
			Impr( cDet , "C",,,03,.T.)
			nTitEmp 	:= 0
			nDepEmp		:= 0
		Endif
	Enddo
	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  ³ Total Por Operadora                                                ³
	  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	If nTotOpeTit> 0 .or. nTotOpeDep > 0
		Impr("","C")                                                                                        
		cDet 	:= oEmToAnsi(STR0005) + space(1)+ LEFT(objCENFUNLGP:verCamNPR("BA0_NOMINT", fDesc("BA0", cOperad,"BA0_NOMINT" )),15) + space(1)
		cDet	+= Transform(nTotOpeTit ,cPict )  + space(1)
		cDet    += Transform(nTotOpeDep ,cPict )  + space(1) 
        cDet	+= Transform( (nTotOpeTit + nTotOpeDep), cPict )
       	Impr(cDet ,"C",,,03,.T.)
		nTotOpeDep	:= 0 
		nTotOpeTit	:= 0 
	Endif
EndDo
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Total Geral  - Resumo                                              ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If nTotTitular > 0 .or.  nTotDepende > 0 
	Impr(""                 ,"C")
	Impr( __PrtThinLine()   ,"C")
	cDet	:= oEmToAnsi(STR0016) 				        + Space(1)
	cDet	+= Transform(nTotTitular,cPict)	            + Space(1)
	cDet	+= Transform(nTotDepende,cPict)          	+ Space(1)
	cDet	+= Transform( nTotTitular + nTotDepende , cPict)
	Impr(cDet        , "C",,,03,.T. )
	Impr(""          , "F")
Endif
	
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Fecha arquivo...                                                   ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
BF1Trb->(DbCloseArea())

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Libera impressao                                                         ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If  aReturn[5] == 1
	Set Printer To
	Ourspool(wnRel)
EndIf
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Fim do Relat¢rio                                                         ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Return