#INCLUDE "PROTHEUS.CH"
#INCLUDE "PCOA122.CH"
#Define GRID_STEP 10000

Static __lBlind		:= IsBlind()
Static _lAtuCubo     := .T.

Function PcoA122(nRecAK1)

Local nX
Local lRet 		:= .F.
Local cAliasTmp
Local cQuery 	:= ""
Local aRecGrid 	:= {}
Local nThread:= SuperGetMv("MV_PCOTHRD",.T.,10)
Default nRecAK1 := AK1->( Recno() )

Pergunte("PCO120",.F.)
_lAtuCubo     := ( mv_par01 == 1 )

cAliasTmp := GetNextAlias() //Obtem o alias para a tabela temporaria
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Query para obter recnos da tabela AK2 ou AK33 da nova versao    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := " SELECT MIN(R_E_C_N_O_) MINRECNOAK, MAX(R_E_C_N_O_) MAXRECNOAK FROM " + RetSqlName( "AK2" )
cQuery += " WHERE "
cQuery += "	           AK2_FILIAL ='" + xFilial( "AK2" ) + "' " 
cQuery += "        AND AK2_ORCAME ='" + cPlanRev + "' "
cQuery += "        AND AK2_VERSAO = '"+ cNewVers +"' "
cQuery += "        AND D_E_L_E_T_= ' ' " 

cQuery := ChangeQuery( cQuery )

dbUseArea( .T., "TOPCONN", Tcgenqry( , , cQuery ), cAliasTmp, .F., .T. )

TcSetField( cAliasTmp, "MINRECNOAK", "N", 12, 0 )
TcSetField( cAliasTmp, "MAXRECNOAK", "N", 12, 0 )

If (cAliasTmp)->(!Eof())

	//DISTRIBUIR EM GRID
	aRecGrid := {}
	For nX := (cAliasTmp)->MINRECNOAK TO (cAliasTmp)->MAXRECNOAK STEP GRID_STEP
		If nX + GRID_STEP > (cAliasTmp)->MAXRECNOAK
			aAdd(aRecGrid, {nx, (cAliasTmp)->MAXRECNOAK } )  //ultimo elemento do array
		Else
			aAdd(aRecGrid, {nx, nX+GRID_STEP-1} )
		EndIf
	Next

	nThread := Min( Len(aRecGrid), nThread ) //Configura a quantidade de threads pelo menor parametro ou len(arecgrid)

	oGrid := FWIPCWait():New("AK1X"+cEmpAnt+StrZero(nRecAK1,9,0),10000)
	oGrid:SetThreads(nThread)
	oGrid:SetEnvironment(cEmpAnt,cFilAnt)
	oGrid:Start("PCOAREVPRC")

	If !MSFile("PCOTMP", ,__CRDD )
		P301CriTmp()				
	EndIf	
	
	If Select("PCOTMP")==0
		dbUseArea(.T.,__CRDD,"PCOTMP","PCOTMP", .T., .F. )
	EndIf		
	
	lRet := A122RevPre(oGrid,aRecGrid,nThread)

EndIf

If _lAtuCubo
	P122AtuCubo(cPlanRev, cNewVers, "02"/*cItemProc*/,"+"/*cSinal*/)
EndIf

ConoutR("[END]->PCOA122: "+TIME(), .T., "PCOA122")

Return(lRet)

/* --------------------------------------------------------------------
Funcao xFilial para uso dentro do corpo das procedures dinamicas do PCO
Recebe como parametro as strings das variaveis da procedure a serem
utilizadas : Alias, Filial atual ou default, e filial de retorno
Retorna o corpo da xfilial a ser executado.
OUTRA OBSERVACAO : Deu erro no AS400 , nao sabemos por que. Reclama de passagem de valores null como parametro.
Nao achamos onde era, e trocamos pela query direta. Funciona, sem erro, e torna esse programa 
totalmente independente da aplicacao de procedures do padrao.
-------------------------------------------------------------------- */
Static Function CallXFilial( cArq )
Local aSaveArea := GetArea()
Local cProc   := cArq+"_"+cEmpAnt
Local cQuery  := ""
Local lRet    := .T.
Local aCampos := CT2->(DbStruct())
Local nPos    := 0
Local cTipo   := ""

cQuery :="Create procedure "+cProc+CRLF
cQuery +="( "+CRLF
cQuery +="  @IN_ALIAS        Char(03),"+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_FILIAL" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery +="  @IN_FILIALCOR    "+cTipo+","+CRLF
cQuery +="  @OUT_FILIAL      "+cTipo+" OutPut"+CRLF
cQuery +=")"+CRLF
cQuery +="as"+CRLF

/* -------------------------------------------------------------------
    Versão      -  <v> Genérica </v>
    Assinatura  -  <a> 010 </a>
    Descricao   -  <d> Retorno o modo de acesso da tabela em questao </d>

    Entrada     -  <ri> @IN_ALIAS        - Tabela a ser verificada
                        @IN_FILIALCOR    - Filial corrente </ri>

    Saida       -  <ro> @OUT_FILIAL      - retorna a filial a ser utilizada </ro>
                   <o> brancos para modo compartilhado @IN_FILIALCOR para modo exclusivo </o>

    Responsavel :  <r> Alice Yaeko </r>
    Data        :  <dt> 14/12/10 </dt>
   
   X2_CHAVE X2_MODO X2_MODOUN X2_MODOEMP X2_TAMFIL X2_TAMUN X2_TAMEMP
   -------- ------- --------- ---------- --------- -------- ---------
   CT2      E       E         E          3.0       3.0        2.0       
      X2_CHAVE   - Tabela
      X2_MODO    - Comparti/o da Filial, 'E' exclusivo e 'C' compartilhado
      X2_MODOUN  - Comparti/o da Unidade de Negócio, 'E' exclusivo e 'C' compartilhado
      X2_MODOEMP - Comparti/o da Empresa, 'E' exclusivo e 'C' compartilhado
      X2_TAMFIL  - Tamanho da Filial
      X2_TAMUN   - Tamanho da Unidade de Negocio
      X2_TAMEMP  - tamanho da Empresa
   
   Existe hierarquia no compartilhamento das entidades filial, uni// de negocio e empresa.
   Se a Empresa for compartilhada as demais entidades DEVEM ser compartilhadas
   Compartilhamentos e tamanhos possíveis
   compartilhaemnto         tamanho ( zero ou nao zero)
   EMP UNI FIL             EMP UNI FIL
   --- --- ---             --- --- ---
    C   C   C               0   0   X   -- 1 - somente filial
    E   C   C               0   X   X   -- 2 - filial e unidade de negocio
    E   E   C               X   0   X   -- 3 - empresa e filial
    E   E   E               X   X   X   -- 4 - empresa, unidade de negocio e filial
------------------------------------------------------------------- */
cQuery +="Declare @cModo    Char( 01 )"+CRLF
cQuery +="Declare @cModoUn  Char( 01 )"+CRLF
cQuery +="Declare @cModoEmp Char( 01 )"+CRLF
cQuery +="Declare @iTamFil  Integer"+CRLF
cQuery +="Declare @iTamUn   Integer"+CRLF
cQuery +="Declare @iTamEmp  Integer"+CRLF

cQuery +="begin"+CRLF
  
cQuery +="  Select @OUT_FILIAL = ' '"+CRLF
cQuery +="  Select @cModo = ' ', @cModoUn = ' ', @cModoEmp = ' '"+CRLF
cQuery +="  Select @iTamFil = 0, @iTamUn = 0, @iTamEmp = 0"+CRLF
  
cQuery +="  Select @cModo = X2_MODO,   @cModoUn = X2_MODOUN, @cModoEmp = X2_MODOEMP,"+CRLF
cQuery +="         @iTamFil = X2_TAMFIL, @iTamUn = X2_TAMUN, @iTamEmp = X2_TAMEMP"+CRLF
cQuery +="    From SX2"+cEmpAnt+"0"+CRLF
cQuery +="   Where X2_CHAVE = @IN_ALIAS"+CRLF
cQuery +="     and D_E_L_E_T_ = ' '"+CRLF
  
  /*   SITUACAO -> 1 somente FILIAL */
cQuery +="  If ( @iTamEmp = 0 and @iTamUn = 0 and @iTamFil >= 2 ) begin"+CRLF   //  -- so tem filial tam 2
cQuery +="    If @cModo = 'C' select @OUT_FILIAL = '  '"+CRLF
cQuery +="    else select @OUT_FILIAL = @IN_FILIALCOR"+CRLF
cQuery +="  end else begin"+CRLF
    /*  SITUACAO -> 2 UNIDADE DE NEGOCIO e FILIAL  */
cQuery +="    If @iTamEmp = 0 begin"+CRLF
cQuery +="      If @cModoUn = 'E' begin"+CRLF
cQuery +="        If @cModo = 'E' select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamUn)||Substring( @IN_FILIALCOR, @iTamUn + 1, @iTamFil )"+CRLF
cQuery +="        else select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamUn)"+CRLF
cQuery +="      end"+CRLF
cQuery +="    end else begin"+CRLF
      /* SITUACAO -> 4 EMPRESA, UNIDADE DE NEGOCIO e FILIAL */
cQuery +="      If @iTamUn > 0 begin"+CRLF
cQuery +="        If @cModoEmp = 'E' begin"+CRLF
cQuery +="          If @cModoUn = 'E' begin"+CRLF
cQuery +="            If @cModo = 'E' select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamEmp)||Substring(@IN_FILIALCOR, @iTamEmp+1, @iTamUn)||Substring( @IN_FILIALCOR, @iTamEmp+@iTamUn + 1, @iTamFil )"+CRLF
cQuery +="            else select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamEmp)||Substring(@IN_FILIALCOR, @iTamEmp+1, @iTamUn)"+CRLF
cQuery +="          end else begin"+CRLF
cQuery +="            select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamEmp)"+CRLF
cQuery +="          end"+CRLF
cQuery +="        end"+CRLF
cQuery +="      end else begin"+CRLF
        /*  SITUACAO -> 3 EMPRESA e FILIAL */
cQuery +="        If @cModoEmp = 'E' begin"+CRLF
cQuery +="          If @cModo = 'E' select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamEmp)||Substring( @IN_FILIALCOR, @iTamEmp+1, @iTamFil )"+CRLF
cQuery +="          else select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamEmp)"+CRLF
cQuery +="        end"+CRLF
cQuery +="      end"+CRLF
cQuery +="    end"+CRLF
cQuery +="  end"+CRLF
cQuery +="end"+CRLF

cQuery := MsParse( cQuery, If( Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB()) ) )
cQuery := CtbAjustaP(.F., cQuery, 0)

If Empty( cQuery )
	MsgAlert(MsParseError(),STR0001+cProc)  //"A query da filial nao passou pelo Parse "
	lRet := .F.
Else
	If !TCSPExist( cProc )
		cRet := TcSqlExec(cQuery)
		If cRet <> 0
			If !__lBlind
				MsgAlert(STR0002+cProc)  //"Erro na criacao da proc filial: "
				lRet:= .F.
			EndIf
		EndIf
	EndIf
EndIf
RestArea(aSaveArea)

Return(lRet)  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³Popula_AK2 ³ Autor ³                         ³ Data ³15.05.13³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Chama as funções q fazem a criação e instalação de procedures ±±
±±³        que geram osníveis superiores p as entidades                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Popula_AK2 (cCodigoAK1, cVerAtu, cNextVer, cArq, aProc  )    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso     ³ SigaPCO                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1=cCodigoAK1 - Codigo da Planilha                       ³±±
±±             ExpC2=cVerAtu    - Versao Atual da Planilha                 ³±±
±±             ExpC3=cNextVer   - Proxima Versão da Planilha               ³±±
±±             ExpC4=cArq       - Nome da procedure Sem a empresa          ³±±
±±             ExpA1=aProc      - Array com as procedures criadas          ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Popula_AK2(cCodigoAK1, cVerAtu, cNextVer, cArq, aProc  )
Local aSaveArea  := GetArea()
Local aCposAK2 := AK2->(DbStruct())
Local cQuery := ""
Local cDeclare := ""
Local cCpoSelect := ""
Local cFetch := ""
Local cInsert:=""
Local cTipo  := ""
Local cProc := cArq+"_"+cEmpAnt
Local iX
Local lRet := .T.
Local nRet := 0
Local nPTratRec := 0

cQuery :="Create Procedure "+cProc+CRLF
cQuery +="("+CRLF
cQuery +="  @IN_FILIAL  Char( "+Str(TamSX3("AK2_FILIAL")[1])+" ),"+CRLF
cQuery +="  @IN_ORCAME  Char( "+Str(TamSX3("AK2_ORCAME")[1])+" ),"+CRLF
cQuery +="  @IN_VERATU  Char( "+Str(TamSX3("AK2_VERSAO")[1])+" ),"+CRLF
cQuery +="  @IN_NEXTVER Char( "+Str(TamSX3("AK2_VERSAO")[1])+" ),"+CRLF
cQuery +="  @OUT_RESULT Char( 01 ) OutPut"+CRLF
cQuery +=" )"+CRLF
cQuery +=" as"+CRLF
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P11 </v>
    Assinatura      - <a>  010 </a>
    Fonte Microsiga - <s>  PCOA120.PRW </s>
    Descricao       - <d>  insere nova versão da revisão no  AK2 </d>
    Funcao do Siga  -      AuxRevisa()
    Entrada         - <ri> @IN_FILIAL  - cFilAnt
                           @IN_ORCAME  - Codigo do orçamento a revisar
                           @IN_VERATU  - Versão atual do orcamento
                           @IN_NEXTVER - Codigo da próxima versão </ri>
    Saida           - <o>  @OUT_RESULT - Indica o termino OK da procedure </ro>
    Responsavel :     <r>  Alice	</r>
    Data        :     15/05/2013
   -------------------------------------------------------------------------------------- */
cQuery +="Declare @cAux        Char( 03 )"+CRLF
cQuery +="Declare @iRecno      Integer"+CRLF
cQuery +="Declare @iNroRegs    Integer"+CRLF
cQuery +="Declare @iTranCount  Integer"+CRLF  // --Var.de ajuste para SQLServer  Será trocada por Commit no CFGX051 após passar pelo Parse

// Adiciona campos no Declare
For iX := 1 to Len( aCposAK2)
	If aCposAK2[ix][2] == "N"
		cTipo := " float "
	Else
		cTipo := " Char("+Str(aCposAK2[iX][3])+")"
	Endif
    cDeclare += "Declare "+If( aCposAK2[ix][2] == "N", "@n", "@c" )+aCposAK2[ix][1]+cTipo+CRLF
Next
cQuery += cDeclare+CRLF

cQuery +="Begin"+CRLF
cQuery +="   Select @OUT_RESULT = '0'"+CRLF
cQuery +="   Select @cAux = 'AK2'"+CRLF
cQuery +="   select @iNroRegs = 0"+CRLF
//Xfilial
cQuery +="   Exec "+aProc[1]+" @cAux, @IN_FILIAL, @cAK2_FILIAL OutPut "+CRLF

cQuery +="   Declare CUR_POPAK2 Insensitive Cursor for"+CRLF
cQuery +="   Select "
// Adiciona campos no Select 
For iX := 1 to Len( aCposAK2)
	cCpoSelect += aCposAK2[Ix][1]
	If iX < Len( aCposAK2)
		cCpoSelect += ", "
	EndIf
Next

cQuery+= cCpoSelect+CRLF
cQuery +="     From "+RetSqlName("AK2")+CRLF
cQuery +="    Where AK2_FILIAL = @cAK2_FILIAL"+CRLF
cQuery +="      and AK2_ORCAME = @IN_ORCAME"+CRLF
cQuery +="      and AK2_VERSAO = @IN_VERATU"+CRLF
cQuery +="      and D_E_L_E_T_ = ' ' "+CRLF
cQuery +="   Order By  AK2_FILIAL, AK2_ORCAME, AK2_VERSAO, AK2_CO"+CRLF  // verificar necessidade
    
cQuery +="   for read only"+CRLF
cQuery +="   Open CUR_POPAK2"+CRLF
// Adiciona campos no Fetch 
For iX := 1 to Len( aCposAK2)
	cFetch  += If(aCposAK2[ix][2] == "N", "@n","@c" )+aCposAK2[Ix][1] 
	If iX < Len( aCposAK2)
		cFetch += ", "
	EndIf
Next
// Valores a serem inseridos no AK2
cInsert:= StrTran(cFetch,"@cAK2_VERSAO","@IN_NEXTVER")+", @iRecno"
cQuery +="   Fetch CUR_POPAK2 into "+cFetch+CRLF /* @cAK2_FILIAL, @cAK2_ID, @cAK2_ORCAME, @cAK2_CO, @cAK2_PERIOD, @cAK2_ID, @cAK2_VERSAO, @cAK2_CO, @cAK2_PERIOD,
												    @cAK2_CC, @cAK2_ITCTB, @cAK2_CLVLR, @cAK2_CLASSE, @nAK2_VALOR,  @cAK2_DESCRI, @cAK2_OPER,  @cAK2_CHAVE,
												    @cAK2_MOEDA,  @cAK2_DATAF, @cAK2_DATAI,  @cAK2_UNIORC, @cAK2_FORM, @cAK2_ENT05, @cAK2_ENT06, @cAK2_ENT07,
												    @cAK2_ENT08,  @cAK2_ENT09 */

cQuery +="   While (@@Fetch_status = 0 ) begin"+CRLF
      
cQuery +="      select @iNroRegs  = @iNroRegs  + 1 "+CRLF
cQuery +="      Select @iRecno = ISNULL( Max( R_E_C_N_O_), 0 ) From "+RetSqlName("AK2")+CRLF
cQuery +="      Select @iRecno = @iRecno + 1"+CRLF
cQuery +="      if @iNroRegs  = 1 begin"+CRLF
cQuery +="         begin tran"+CRLF
cQuery +="         select @iNroRegs  = @iNroRegs "+CRLF
cQuery +="      end"+CRLF
cQuery +="      ##TRATARECNO @iRecno\"+CRLF
cQuery +="      Insert into "+RetSqlName("AK2")+" ( "+ cCpoSelect + ", R_E_C_N_O_ )"+ CRLF /*AK2_FILIAL, AK2_ID, AK2_ORCAME, AK2_VERSAO, AK2_CO, AK2_PERIOD, AK2_CC, AK2_ITCTB, AK2_CLVLR, AK2_CLASSE, AK2_VALOR, AK2_DESCRI, AK2_OPER, AK2_CHAVE,
												                   AK2_MOEDA,  AK2_DATAF, AK2_DATAI, AK2_UNIORC, AK2_ENT05, AK2_ENT06, AK2_ENT07, AK2_ENT08, AK2_ENT09, AK2_FORM, AK2_FORMUL, R_E_C_N_O_ )*/
cQuery +="           Values( "+cInsert+" )"+CRLF /* @cAK2_FILIAL, @cAK2_ID,    @cAK2_ORCAME, @cAK2_CO,    @cAK2_PERIOD, @cAK2_ID,    @cAK2_VERSAO, @cAK2_CO, @cAK2_PERIOD, @cAK2_CC, @cAK2_ITCTB, @cAK2_CLVLR, @cAK2_CLASSE,
							                   @nAK2_VALOR,  @cAK2_DESCRI, @cAK2_OPER,  @cAK2_CHAVE, @cAK2_MOEDA,  @cAK2_DATAF, @cAK2_DATAI,  @cAK2_UNIORC, @cAK2_FORM, @cAK2_ENT05, @cAK2_ENT06, @cAK2_ENT07, @cAK2_ENT08,  @cAK2_ENT09*/
cQuery +="      ##FIMTRATARECNO"+CRLF
cQuery +="      if @iNroRegs  >= 5000 begin "+CRLF
cQuery +="         commit tran"+CRLF
cQuery +="         Select @iNroRegs  = 0"+CRLF
cQuery +="      end"+CRLF
cQuery +="      Fetch CUR_POPAK2 into "+cFetch+CRLF /* @cAK2_FILIAL, @cAK2_ID,    @cAK2_ORCAME, @cAK2_CO,    @cAK2_PERIOD, @cAK2_ID,    @cAK2_VERSAO, @cAK2_CO, @cAK2_PERIOD, @cAK2_CC, @cAK2_ITCTB, @cAK2_CLVLR, @cAK2_CLASSE,"+CRLF
											            @nAK2_VALOR,  @cAK2_DESCRI, @cAK2_OPER,  @cAK2_CHAVE, @cAK2_MOEDA,  @cAK2_DATAF, @cAK2_DATAI,  @cAK2_UNIORC, @cAK2_FORM, @cAK2_ENT05, @cAK2_ENT06, @cAK2_ENT07, @cAK2_ENT08,  @cAK2_ENT09"*/
cQuery +="   End"+CRLF
   
cQuery +="   if @iNroRegs  > 0 begin"+CRLF
cQuery +="      commit Tran"+CRLF
cQuery +="      Select @iTranCount  = 0"+CRLF
cQuery +="   end"+CRLF
   
cQuery +="   Close CUR_POPAK2"+CRLF
cQuery +="   deallocate CUR_POPAK2"+CRLF
   
cQuery +="   Select @OUT_RESULT = '1'"+CRLF
cQuery +="End"+CRLF

cQuery := CtbAjustaP(.T., cQuery, @nPTratRec)
cQuery := MsParse(cQuery,If(Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB())))
cQuery := CtbAjustaP(.F., cQuery, nPTratRec)

If !TCSPExist( cProc )
	nRet := TcSqlExec(cQuery)
	If nRet <> 0 
		If !__lBlind
			MsgAlert(STR0003+cProc)  //"Erro na criacao da procedure de inserção de AK2, função Popula_AK2 :"
			lRet:= .F.
		EndIf
	EndIf
EndIf

RestArea(aSaveArea)
Return lRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³Popula_AK3 ³ Autor ³                       ³ Data ³16.05.13  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Chama as funções q fazem a criação e instalação de procedures ±±
±±³        que geram osníveis superiores p as entidades                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³AuxRevis( cArquivo, cAliasAKW, cPlano )                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso     ³ SigaPCO                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = cArquivo  - nome da Tabela a popular                ³±±
±±             ExpC2 = cAliasAKW - Alias para o qual a tabela sera populada³±±
±±             ExpC3 = cPlano - codigo do Plano -> '05', '06' somente para ³±±
±±                     as novas entidades - Entidades que estão no CV0     ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Popula_AK3(cCodigoAK1, cVerAtu, cNextVer, cArq, aProc, cArqTemp )
Local aSaveArea  := GetArea()
Local aCposAK3 := AK3->(DbStruct())
Local cQuery := ""
Local cDeclare := ""
Local cCpoSelect := ""
Local cFetch := ""
Local cInsert:= ""
Local cTipo  := ""
Local cProc := cArq+"_"+cEmpAnt
Local iX
Local lRet := .T.
Local nRet := 0
Local nPTratRec := 0

cQuery :="Create Procedure "+cProc+CRLF
cQuery +="( "+CRLF
cQuery +="  @IN_FILIAL  Char( "+Str(TamSX3("AK3_FILIAL")[1])+" ),"+CRLF
cQuery +="  @IN_ORCAME  Char( "+Str(TamSX3("AK3_ORCAME")[1])+" ),"+CRLF
cQuery +="  @IN_VERATU  Char( "+Str(TamSX3("AK3_VERSAO")[1])+" ),"+CRLF
cQuery +="  @IN_NEXTVER Char( "+Str(TamSX3("AK3_VERSAO")[1])+" ),"+CRLF
cQuery +="   @OUT_RESULT Char( 01 ) OutPut"+CRLF
cQuery +=" )"+CRLF
cQuery +=" as"+CRLF
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P11 </v>
    Assinatura      - <a>  010 </a>
    Fonte Microsiga - <s>  PCOA120.PRW </s>
    Descricao       - <d>  insere nova versão da revisão no  AK2 </d>
    Funcao do Siga  -      AuxRevisa()
    Entrada         - <ri> @IN_FILIAL  - cFilAnt
                           @IN_ORCAME  - Codigo do orçamento a revisar
                           @IN_VERATU  - Versão atual do orcamento
                           @IN_NEXTVER - Codigo da próxima versão </ri>
    Saida           - <o>  @OUT_RESULT - Indica o termino OK da procedure </ro>
    Responsavel :     <r>  Alice	</r>
    Data        :     15/05/2013
   -------------------------------------------------------------------------------------- */
cQuery +="Declare @cAux        Char( 03 )"+CRLF
cQuery +="Declare @iRecno      Integer"+CRLF
cQuery +="Declare @iNroRegs    Integer"+CRLF
cQuery +="Declare @iTranCount  Integer"+CRLF  // --Var.de ajuste para SQLServer  Será trocada por Commit no CFGX051 após passar pelo Parse

// Adiciona campos no Declare
For iX := 1 to Len( aCposAK3 )
	If aCposAK3[ix][2] == "N"
		cTipo := " float "
	ElseIf aCposAK3[ix][2] == "M"
		If Alltrim(TcGetDb()) $ "MSSQL|MSSQL7"
			cTipo := " Varbinary "
		ElseIf Alltrim(TcGetDb()) $ "ORACLE|DB2"
			cTipo := " Blob "			
		Endif
	Else
		cTipo := " Char("+Str(aCposAK3[iX][3])+")"
	Endif
    cDeclare += "Declare "+Iif( aCposAK3[ix][2] == "N", "@n", "@c" )+(aCposAK3[ix][1])+cTipo+CRLF
Next
cQuery += cDeclare+CRLF

cQuery +="Begin"+CRLF
cQuery +="   Select @OUT_RESULT = '0'"+CRLF
cQuery +="   Select @cAux = 'AK3'"+CRLF
cQuery +="   select @iNroRegs = 0"+CRLF
// xFilial   
cQuery +="   Exec "+aProc[1]+" @cAux, @IN_FILIAL, @cAK3_FILIAL OutPut "+CRLF

cQuery +="   Declare CUR_POPAK3 Insensitive Cursor for"+CRLF
cQuery +="   Select "
// Adiciona campos no Select 
For iX := 1 to Len( aCposAK3)
	cCpoSelect += aCposAK3[Ix][1]
	If iX < Len( aCposAK3)
		cCpoSelect += ", "
	EndIf
Next

cQuery+= cCpoSelect+CRLF
cQuery +="     From "+RetSqlName("AK3")+CRLF
cQuery +="    Where AK3_FILIAL = @cAK3_FILIAL"+CRLF
cQuery +="      and AK3_ORCAME = @IN_ORCAME"+CRLF
cQuery +="      and AK3_VERSAO = @IN_VERATU"+CRLF
cQuery +="      and D_E_L_E_T_ = ' ' "+CRLF
cQuery +="   Order By  AK3_FILIAL, AK3_ORCAME, AK3_VERSAO, AK3_CO"+CRLF  // verificar necessidade
    
cQuery +="   for read only"+CRLF
cQuery +="   Open CUR_POPAK3"+CRLF
// Adiciona campos no Fetch 
For iX := 1 to Len( aCposAK3)
	cFetch += Iif( aCposAK3[ix][2] == "N", "@n", "@c" )+(aCposAK3[ix][1])
	If iX < Len( aCposAK3)
		cFetch += ", "
	EndIf
Next
// Valores a serem inseridos no AK3
cInsert:= StrTran(cFetch,"@cAK3_VERSAO","@IN_NEXTVER")+", @iRecno"
cQuery +="   Fetch CUR_POPAK3 into "+cFetch+CRLF /* @cAK3_FILIAL, @cAK3_ORCAME, @cAK3_VERSAO, @cAK3_CO, @cAK3_PAI, @cAK3_TIPO, @cAK3_NIVEL, @cAK3_DESCRI,
													@iAK3_MEMO, @cAK3_SEQ, @cAK3_LOGLCK */

cQuery +="   While (@@Fetch_status = 0 ) begin"+CRLF
      
cQuery +="      select @iNroRegs  = @iNroRegs  + 1 "+CRLF
//Inserir recnos do AK3, cujo campo Memo/imagem no rquivo temporário 
/*cQuery +="      If @cAK3_MEMO is not null begin"+CRLF
cQuery +="         insert into "+cArqTEmp+"(  R_E_C_N_O_ )"+CRLF
cQuery +="                   Values(@iR_E_C_N_O_)"+CRLF
cQuery +="      End"+CRLF*/

cQuery +="      Select @iRecno = ISNULL( Max(R_E_C_N_O_), 0 ) From "+RetSqlName("AK3")+CRLF
cQuery +="      Select @iRecno = @iRecno + 1"+CRLF
cQuery +="      if @iNroRegs  = 1 begin"+CRLF
cQuery +="         begin tran"+CRLF
cQuery +="         select @iNroRegs  = @iNroRegs "+CRLF
cQuery +="      end"+CRLF
cQuery +="      ##TRATARECNO @iRecno\"+CRLF
cQuery +="      Insert into "+RetSqlName("AK3")+" ( "+ cCpoSelect + ", R_E_C_N_O_ )"+ CRLF /* AK3_FILIAL, AK3_ORCAME, AK3_VERSAO, AK3_CO, AK3_PAI,,AK3_TIPO, AK3_NIVEL, AK3_DESCRI,
													                AK3_MEMO, AK3_SEQ, AK3_LOGLCK, R_E_C_N_O_ */
cQuery +="           Values( "+cInsert+" )"+CRLF /* @cAK3_FILIAL, @cAK3_ORCAME, @cAK3_VERSAO, @cAK3_CO, @cAK3_PAI, @cAK3_TIPO, @cAK3_NIVEL, @cAK3_DESCRI,
													@iAK3_MEMO, @cAK3_SEQ, @cAK3_LOGLCK */
cQuery +="      ##FIMTRATARECNO"+CRLF
cQuery +="      if @iNroRegs  >= 5000 begin "+CRLF
cQuery +="         commit tran "+CRLF
cQuery +="         Select @iNroRegs  = 0"+CRLF
cQuery +="      end"+CRLF
cQuery +="      Fetch CUR_POPAK3 into "+cFetch+CRLF /* @cAK3_FILIAL, @cAK3_ORCAME, @cAK3_VERSAO, @cAK3_CO, @cAK3_PAI, @cAK3_TIPO, @cAK3_NIVEL, @cAK3_DESCRI,
					        							@iAK3_MEMO, @cAK3_SEQ, @cAK3_LOGLCK */
cQuery +="   End"+CRLF
   
cQuery +="   if @iNroRegs  > 0 begin"+CRLF
cQuery +="      commit tran"+CRLF
cQuery +="      Select @iTranCount  = 0"+CRLF
cQuery +="   end"+CRLF

cQuery +="   Close CUR_POPAK3"+CRLF
cQuery +="   deallocate CUR_POPAK3"+CRLF
   
cQuery +="   Select @OUT_RESULT = '1'"+CRLF
cQuery +="End"+CRLF

cQuery := CtbAjustaP(.T., cQuery, @nPTratRec)
cQuery := MsParse(cQuery,If(Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB())))
cQuery := CtbAjustaP(.F., cQuery, nPTratRec)

If !TCSPExist( cProc )
	nRet := TcSqlExec(cQuery)
	If nRet <> 0 
		If !__lBlind
			MsgAlert(STR0004+cProc) //"Erro na criacao da procedure de inserção de AK3, função, Popula_AK3 "
			lRet:= .F.
		EndIf
	EndIf
EndIf

RestArea(aSaveArea)
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³PcoCriaPai ³ Autor ³                       ³ Data ³16.05.13  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Chama as funções q fazem a criação e instalação de procedures ±±
±±³        que geram osníveis superiores p as entidades                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PcoCriaPai( cArq, aProc  )                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso     ³ SigaPCO                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = cArq  - Nome da procedure sem a empresa             ³±±
±±             ExpC2 = aProc - Array com procedures criadas                ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PcoCriaPai( cArq, aProc  )
Local aSaveArea  := GetArea()
Local cQuery := ""
Local cProc := cArq+"_"+cEmpAnt
Local lRet := .T.
Local nRet := 0

cQuery :="Create Procedure "+cProc+CRLF
cQuery +="( "+CRLF
cQuery +="   @IN_FILIAL    Char( "+Str(TamSX3("AK1_FILIAL")[1])+" ),"+CRLF
cQuery +="   @IN_CODIGOAK1 Char( "+Str(TamSX3("AK1_CODIGO")[1])+" ),"+CRLF
cQuery +="   @IN_VERATU    Char( "+Str(TamSX3("AK1_VERSAO")[1])+" ),"+CRLF
cQuery +="   @IN_NEXTVER   Char( "+Str(TamSX3("AK1_VERSAO")[1])+" ),"+CRLF
cQuery +="   @OUT_RESULT   Char( 01 ) OutPut"+CRLF
cQuery +=")"+CRLF

cQuery +="as"+CRLF
/* --------------------------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P11 </v>
    Assinatura      - <a>  010 </a>
    Fonte Microsiga - <s>  PCOA122.PRW </s>
    Descricao       - <d>  Faz chamada das procedure de inserçãode nova versão AK2 e AK3 </d>
    Funcao do Siga  -      AuxRevisa()
    Entrada         - <ri> @IN_FILIAL    - cFilAnt
                           @IN_CODIGOAK1 - Codigo do orçamento a revisar
                           @IN_VERATU    - Versão atual do orcamento
                           @IN_NEXTVER   - Codigo da próxima versão </ri>
    Saida           - <o>  @OUT_RESULT   - Indica o termino OK da procedure </ro>
    Responsavel :     <r>  	</r>
    Data        :     16/05/2013
   -------------------------------------------------------------------------------------------------------- */
cQuery +="Declare @cRetorno char( 01 )"+CRLF

cQuery +="Begin"+CRLF

cQuery +="   Select @OUT_RESULT = '0'"+CRLF
cQuery +="   Select @cRetorno = '0'"+CRLF
   // Chama procedure de iserção no AK2
cQuery +="   Exec "+aProc[2]+" @IN_FILIAL, @IN_CODIGOAK1, @IN_VERATU, @IN_NEXTVER, @cRetorno OutPut"+CRLF
   
cQuery +="   If @cRetorno = '1' begin"+CRLF
   // Chama procedure de iserção no AK3
cQuery +="      Exec "+aProc[3]+" @IN_FILIAL, @IN_CODIGOAK1, @IN_VERATU, @IN_NEXTVER, @cRetorno OutPut"+CRLF
cQuery +="   End"+CRLF
cQuery +="   If @cRetorno = '1' begin"+CRLF
cQuery +="      Select @OUT_RESULT = '1'"+CRLF
cQuery +="   End"+CRLF
cQuery +="End"+CRLF

cQuery := MsParse(cQuery,If(Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB())))

If !TCSPExist( cProc )
	nRet := TcSqlExec(cQuery)
	If nRet <> 0 
		If !__lBlind
			MsgAlert(STR0005+cProc)  //'Erro na criacao da procedure Principal '
			lRet:= .F.
		EndIf
	EndIf
EndIf

RestArea(aSaveArea)
Return lRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³PcoProcRev ³ Autor ³                       ³ Data ³16.05.13  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Chama as funções q fazem a criação e instalação de procedures ±±
±±³        que geram osníveis superiores p as entidades                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PcoProcRev(cCodigoAK1, cVerAtu, cNextVer, aAliasCpy, aRecAK3,³±± 
±±³			             aRecNew,   lSimulac,lRevisao,  lPCOCOP )          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso     ³ SigaPCO                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = cCodigoAK1 - Codigo da Planilha                     ³±±
±±             ExpC2 = cVerAtu    - Versao Atual da Planilha               ³±±
±±             ExpC3 = cNextVer   - Próxima versão da Planilha             ³±±
±±             ExpA1 = aAliasCpy  -                                        ³±±
±±             ExpA2 = aRecAK3    - Recnos do AK3 da versao atual          ³±±
±±             ExpA3 = aRecNew    - Recnos do AK3 da nova versao           ³±±
±±             ExpL1 = lSimulac   - Se .T., simulação                      ³±±
±±             ExpL2 = lRevisao   - Se .T., revisao                        ³±±
±±             ExpL3 = lPCOCOP    -                                         ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PcoProcRev(cCodigoAK1, cVerAtu, cNextVer, aAliasCpy, aRecAK3, aRecNew, lSimulac, lRevisao, lPCOCOP )
Local aAreaAK2:= GetArea("AK2")
Local aAreaAK3:= GetArea("AK3")
Local aResult := {}
Local lRet    := .T.
Local aProc   := {}
Local nProx   := 1
//Local cArqTab
Local cArq
Local cArqTemp
Local cAliasTmp
Local iX
Local nRecNew := 0
Local nThread:= SuperGetMv("MV_PCOTHRD",.T.,10)

Private cPlanRev    := AK1->AK1_CODIGO
Private cNewVers 	:= cNextVer   //variaveis para multi-thread
Private lSimu_ 		:= lSimulac 
Private lRevi_      := lRevisao

Private oGrid
Private lAuto

If nThread < 2 .Or. nThread > 30
	Help(" ",1,"PCOA120IRV",,STR0006,1,0)  //"Quantidade de Thread não permitida."
	Return(.F.)
EndIf 

If !LockByName("PCOA120"+cEmpAnt+xFilial("AKE")+cCodigoAK1+cVerAtu+cNextVer,.F.,.F.)
	Help(" ",1,"PCOA120US",,STR0007,1,0) //"Outro usuario está usando a rotina "
	Return(.F.)
EndIf

/* ------------------------------------------------------------------------------------------------------------------------------------------
	   Gerar nome para procedures temporárias  CriaTrab
	
	1. Cria xfilial  
		- CallXfilial .....................................................-  aProc[1]
	2. Cria e Instala Procedure de inserção de dados no AK2 
		- Popula_AK2  .....................................................-  aProc[2]
    3. Cria tabela temporária para copiar AK3 recnos de linhas com campo memo
    
	4. Cria e Instala Procedure de inserção de dados no AK3
		- Popula_AK3 .......................................................- aProc[3]
	5. Cria e Instala Procedure Pai - Chama a inserção do AK2 e AK3
		- PcoCriaPai .......................................................- aProc[4]
   ------------------------------------------------------------------------------------------------------------------------------------------ */
// Gerar nome para procedures temporárias  SCNNNN01//
cArqTrb := CriaTrab(,.F.)
cArq    := cArqTRB+StrZero(nProx,2)
AADD( aProc, cArq+"_"+cEmpAnt)
//	1. Cria xfilial  
//		- CallXfilial .....................................................-  aProc[1]
lRet := CallXFilial( cArq )
//	2. Cria e Instala Procedure de inserção de dados no AK2 
//		- Popula_AK2  .....................................................-  aProc[2]
If lRet
	nProx := nProx + 1
	cArq  := cArqTRB+StrZero(nProx,2)
	cArqAKT := cArq
	AADD( aProc, cArq+"_"+cEmpAnt)
	lRet := Popula_AK2(cCodigoAK1, cVerAtu, cNextVer,cArq, aProc )
EndIf
//	3. Cria e Instala Procedure de inserção de dados no AK3
//		- Popula_AK3 .......................................................- aProc[3]
If lRet
	/* -------------------------------------------------------------------------
		4. Cria e Instala Procedure que insere dados no AK3 e popula Temporário.
	   ------------------------------------------------------------------------- */
	nProx := nProx + 1
	cArq  := cArqTRB+StrZero(nProx,2)
	cArqAKT := cArq
	AADD( aProc, cArq+"_"+cEmpAnt )
	lRet := Popula_AK3(cCodigoAK1, cVerAtu, cNextVer, cArq, aProc, cArqTemp  )
EndIf
//	5. Cria e Instala Procedure Pai - Chama a inserção do AK2 e AK3
//		- PcoCriaPai .......................................................- aProc[4]
If lRet
	nProx := nProx + 1
	cArq  := cArqTRB+StrZero(nProx,2)
	cArqAKT := cArq
	AADD( aProc, cArq+"_"+cEmpAnt)
	lRet := PcoCriaPai(cArq, aProc )
EndIf
// Faz a execução da procedure 
If lRet
	aResult := TCSPExec( xProcedures(cArq), cFilAnt, cCodigoAK1, cVerAtu, cNextVer )
	TcRefresh(RetSqlName("AK2"))
	TcRefresh(RetSqlName("AK3"))
	If Empty(aResult) .Or. aResult[1] = "0"
		MsgAlert(tcsqlerror(),STR0008+cArq )   //"Erro na inclusão de dados no AK2, AK3 "
		lRet := .F.
	EndIf
EndIf

// Procedures 'Dropar'
// Procedures - aProc[1],.., aProc[4]
For iX = 1 to Len(aProc)   // exclusao de aProc
	If TCSPExist(aProc[iX])
		cExec := "Drop procedure "+aProc[iX]
		cRet := TcSqlExec(cExec)
		If cRet <> 0
			MsgAlert(STR0009+aProc[iX] +STR0010) //"Erro na exclusao da Procedure: "###". Excluir manualmente no banco"
		Endif
	EndIf
Next iX

// Faz chamada da DETLAN 
If lRet
	//select ak3 da versao atual para gravar os recnos no array aRecAK3 
	IncProc() //Incrementa valor na regua de progressao
	cAliasTmp := GetNextAlias() //Obtem o alias para a tabela temporaria
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Query para obter recnos da tabela AK2 ou AK3 da nova versao    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := " SELECT R_E_C_N_O_ RECNOAK FROM " + RetSqlName( "AK3" )
	cQuery += " WHERE "
	cQuery += "	           AK3_FILIAL ='" + xFilial( "AK3" ) + "' " 
	cQuery += "        AND AK3_ORCAME ='" + AK1->AK1_CODIGO          + "' "
	cQuery += "        AND AK3_VERSAO = '"+cVerAtu+"' "
	cQuery += "        AND D_E_L_E_T_= ' ' " 
	cQuery += " ORDER BY R_E_C_N_O_"
	
	cQuery := ChangeQuery( cQuery )
	
	dbUseArea( .T., "TOPCONN", Tcgenqry( , , cQuery ), cAliasTmp, .F., .T. )
	
	TcSetField( cAliasTmp, "RECNOAK", "N", 12, 0 )
	                                          
	While (cAliasTmp)->(!Eof())
		nRecNew := (cAliasTmp)->(RECNOAK)
		aAdd(aRecAK3, nRecNew)	//Armazena o recno da versao atual
		(cAliasTmp)->(dbSkip())
	EndDo
	(cAliasTmp)->(dbCloseArea() )

	//select ak3 da versao atual para gravar os recnos no array aRecNew
	IncProc() //Incrementa valor na regua de progressao
	cAliasTmp := GetNextAlias() //Obtem o alias para a tabela temporaria
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Query para obter recnos da tabela AK2 ou AK3 da nova versao    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := " SELECT R_E_C_N_O_ RECNOAK FROM " + RetSqlName( "AK3" )
	cQuery += " WHERE "
	cQuery += "	           AK3_FILIAL ='" + xFilial( "AK3" ) + "' " 
	cQuery += "        AND AK3_ORCAME ='" + AK1->AK1_CODIGO          + "' "
	cQuery += "        AND AK3_VERSAO = '"+cNextVer+"' "
	cQuery += "        AND D_E_L_E_T_= ' ' " 
	cQuery += " ORDER BY R_E_C_N_O_"
	
	cQuery := ChangeQuery( cQuery )
	
	dbUseArea( .T., "TOPCONN", Tcgenqry( , , cQuery ), cAliasTmp, .F., .T. )
	
	TcSetField( cAliasTmp, "RECNOAK", "N", 12, 0 )
	                                          
	While (cAliasTmp)->(!Eof())
		nRecNew := (cAliasTmp)->(RECNOAK)
		aAdd(aRecNew, nRecNew)	//Armazena o recno da nova versao
		(cAliasTmp)->(dbSkip())
	EndDo
	(cAliasTmp)->(dbCloseArea() )

	IncProc() //Incrementa valor na regua de progressao

	PcoA122( AK1->(Recno()) ) //distribui os registros copiados para gerar akd pelo pcodetlan/pcofinlan
	
EndIf

UnLockByName("PCOA120"+cEmpAnt+xFilial("AKE")+cCodigoAK1+cVerAtu+cNextVer,.F.,.F.)

RestArea( aAreaAK2 )       
RestArea( aAreaAK3 )
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A122RevPre ºAutor  ³Microsiga           º Data ³  14/06/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Prepara a execução da rotina em MultiThreads                º±±
±±º          ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A122RevPre(oGrid,aRecGrid,nThread)
Local nRecIni
Local nRecFim

Local cFilAKE 	:= xFilial("AKE")
Local lExit 	:= .F.
Local nKilled
Local nHdl
Local cMsgComp	:= ""
Local nX
Local nZ
Local cArquivo := ""

cArquivo := CriaTrab(,.F.)

For nX := 1 To Len(aRecGrid)
	nRecIni := aRecGrid[nX,1]
	nRecFim := aRecGrid[nX,2]
	lRet := oGrid:Go(STR0011,{nRecIni, nRecFim, lSimu_, lRevi_, cPlanRev, cNewVers, nX},cArquivo)  //"Chamando escrituracao..."
	If !lRet
		Exit
	EndIf

	Sleep(5000)//Aguarda 5 seg para abertura da thread para não concorrer na criação das procedures.

Next

Sleep(2500*nThread)//Aguarda todas as threads abrirem para tentar fechar
    
While !lExit
	nKilled := P301ChkThd("PCOA122",cArquivo)

	If nKilled == Len(aRecGrid)
		Exit
	EndIf
	
	Sleep(3000) //Verifica a cada 3 segundos se as threads finalizaram
	
EndDo

cMsgComp := P301MsgCom("PCOA122",cArquivo)
	
P301DelTmp("PCOA122",cArquivo)

PcoAvisoTm(IIf(lRet,STR0012, STR0016),cMsgComp, {"Ok"},,,,,5000) //"Processo finalizado com sucesso."###"Problema no processamento."

// Fechamento das Threads
oGrid:Stop()        //Metodo aguarda o encerramento de todas as threads antes de retornar o controle.

oGrid:RemoveThread(.T.)

FreeObj(oGrid)
oGrid := nil

Return lRet	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOAREVPRC ºAutor  ³Microsiga           º Data ³  14/06/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Rotina executado em MultiThread para chamara a funcao que  º±±
±±º          ³  ira executar PcoDetLan                                     º±±  
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCOAREVPRC(cParm,aParam,cArquivo)
Local nRecIni 	:= aParam[1]
Local nRecFim 	:= aParam[2]
Local lSimulac 	:= aParam[3]
Local lRevisa 	:= aParam[4]
Local cPlanRev  := aParam[5]
Local cNewVers  := aParam[6]
Local nZ		:= aParam[7]
Local cFilAKE 	:= xFilial("AKE")
Local nRecPCO   := 0

Local nHdl 
Local cStart	:= ""
Local cEnd      := ""
DEFAULT cArquivo:= ""

If Select("PCOTMP")==0
	dbUseArea(.T.,__CRDD,"PCOTMP","PCOTMP", .T., .F. )
EndIf


If LockByName("PCOA120_"+cFilAKE+cPlanRev+cNewVers+StrZero(nZ,10,0),.T.,.T.)
	cStart := DTOC(Date())+" "+Time()		
	ConoutR( "PCOA120 -> "+AllTrim(Str(ThreadID()))+" STARTED ["+cStart+"] " ) 
	PCOTMP->(RecLock("PCOTMP",.T.))
		PCOTMP->CPOLOG := "  [DETLAN] STARTED ["+cStart+"]" 
    	PCOTMP->ORIGEM := "PCOA122"  
    	PCOTMP->ARQUIVO:= cArquivo
    	PCOTMP->STATUS := "0"	  
    PCOTMP->(MsUnLock())

    nRecPCO := PCOTMP->(RECNO())
    //PROCESSAMENTO
	lRet := Aux_Det_Lan(nRecIni, nRecFim, lSimulac, lRevisa, cPlanRev, cNewVers)
	
	cEnd := DTOC(Date())+" "+Time()
	
    PCOTMP->(dbGoTo(nRecPCO))
	PCOTMP->(RecLock("PCOTMP",.F.))
    	
    	If lRet	
    		ConoutR("PCOA120 -> "+AllTrim(Str(ThreadID()))+" END   ["+cEnd+"]  OK")
			PCOTMP->CPOLOG := AllTrim(PCOTMP->CPOLOG)+ "  END ["+cEnd+"] - OK"
		Else
			ConoutR("PCOA120 -> "+AllTrim(Str(ThreadID()))+" END   ["+cEnd+"]  FAILED")
			PCOTMP->CPOLOG := AllTrim(PCOTMP->CPOLOG)+ "  END ["+cEnd+"] - FAILED"
	    EndIf	 
	    PCOTMP->STATUS := "1"
    PCOTMP->(MsUnLock())
    
	UnLockByName("PCOA301_"+cFilAKE+cPlanRev+cNewVers+StrZero(nZ,10,0),.T.,.T.)

EndIf
	
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Aux_Det_Lan ºAutor  ³Microsiga         º Data ³  06/14/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Chama a PcoDetLan para escriturar movimento gerado por      º±±
±±º          ³Iniciar Revisao (distribuido)                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Aux_Det_Lan(nRecIni, nRecFim, lSimulac, lRevisao, cPlanRev, cNewVers)
Local lRet := .F.
Local cQuery := " "
Local nCtdAK2 := 0

//select ak2 da versao nova
cAliasTmp := GetNextAlias() //Obtem o alias para a tabela temporaria
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Query para obter recnos da tabela AK2 ou AK3 da nova versao    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := " SELECT R_E_C_N_O_ RECNOAK FROM " + RetSqlName( "AK2" )
cQuery += " WHERE "
cQuery += "	           AK2_FILIAL ='" + xFilial( "AK2" ) + "' " 
cQuery += "        AND AK2_ORCAME ='" + cPlanRev + "' "
cQuery += "        AND AK2_VERSAO = '"+ cNewVers +"' "
cQuery += "        AND R_E_C_N_O_ BETWEEN  "+ Str(nRecIni,12,0) + " AND "+ Str(nRecFim,12,0)
cQuery += "        AND D_E_L_E_T_ = ' ' " 
cQuery += " ORDER BY R_E_C_N_O_ "

cQuery := ChangeQuery( cQuery )

dbUseArea( .T., "TOPCONN", Tcgenqry( , , cQuery ), cAliasTmp, .F., .T. )

TcSetField( cAliasTmp, "RECNOAK", "N", 12, 0 )
ConoutR(STR0013+Str(nRecIni,12,0)+STR0014+Str(nRecFim,12,0)+time()) // "inicio Recnos de:"###" Ate: "
PcoIniLan("000252")

While (cAliasTmp)->(!Eof())
	nRecNew := (cAliasTmp)->(RECNOAK)
	AK2->(dbGoto(nRecNew))
	nCtdAK2++	
	If lSimulac
		PcoDetLan("000252","03","PCOA100",/*lDeleta*/, /*cProcDel*/, "1")
	ElseIf lRevisao
		PcoDetLan("000252","02","PCOA100",/*lDeleta*/, /*cProcDel*/, "1")
	EndIf
	(cAliasTmp)->(dbSkip())
EndDo

PcoFinLan("000252",/*lForceVis*/,/*lProc*/,/*lDelBlq*/,.F./*lAtuSld*/)

(cAliasTmp)->(dbCloseArea() )

ConoutR(STR0015+Str(nRecIni,12,0)+STR0014+Str(nRecFim,12,0)+time())  //"Final Recnos de: "###" Ate: "

lRet := ( (nRecFim-nRecIni+1) == nCtdAK2 )

Return(lRet)


/*-----------------------------------------------------------------------------------------*/
//atualizacao dos cubos                                                                    //
/*-----------------------------------------------------------------------------------------*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³P122AtuCubo ºAutor  ³Microsiga         º Data ³  21/06/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Chamador procedure para atualizar saldo na revisao da       º±±
±±º          ³planilha orcamentaria                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function P122AtuCubo(cPlanRev, cVersPlan, cItemProc, cSinal)
Local aTmpDim := {}
Local aNivel := {}
Local cProcSup := ""
Local cExecDrop := ""
Local nRetDrop := 0
Local nX
Local aTdaNiveis := {}
Local nZ

If _lAtuCubo
    
	aTmpDim := {}
	dbSelectArea("AL1")
	dbSeek(xFilial("AL1"))   //posiciona na filial
	While AL1->( ! Eof() .And. AL1_FILIAL = xFilial("AL1") )  //enquanto for da mesma filial
	
		aNivel := PcoGeraSup(AL1->AL1_CONFIG,aTmpDim)
		
		If Len(aNivel) > 0
			aAdd( aTdaNiveis, aClone(aNivel) )
		EndIf
			
		//Verifica se a estrutura do cubo existe	
		dbSelectArea("AKW") 
		AKW->(dbSetOrder(1))
		If AKW->(dbSeek(xFilial("AKW")+AL1->AL1_CONFIG))
		    //Verifica se o cubo está liberado
			While .T.
				If AL1->(dbRLock())							
					PcoCubeStatus("2")	//Bloquear o cubo com RecLock() para ninguem atualiza-lo durante o processamento			
					If 	P122CallProc(aNivel, cPlanRev, cVersPlan, cItemProc, cSinal)
						lRet := .T.
					EndIf
					
					dbSelectArea("AL1")
					//libera o lock do registro referente ao cubo gerencial
			   		PcoCubeStatus("1")		
					AL1->(dbRUnlock())
					Exit
				Else
					If PcoAvisoTm(STR0017,STR0018+AL1->AL1_CONFIG+CRLF+;  //"Atencao"###"Atualizacao de Saldos do Cubo : "
											STR0019+CRLF+;  //"Cubo em Uso. Tente novamente!"
											STR0020, {STR0021,STR0022},3,,,,5000)  == 2 //"Caso Abandone os cubos deverao ser reprocessados."###"Ok"###"Abandonar"
						ConoutR(STR0023) //"Atualizacão de saldos do cubo foi abandonada na revisao da planilha e deve ser reprocessado apos finalizacao"
						P122lAtuCb( .F. ) //seta _lAtuCubo := .F.
						Exit
					EndIf
				EndIf
			EndDo
		EndIf
		
		AL1->( dbSkip() )
	
	EndDo

		
	For nZ := 1 TO Len(aTdaNiveis)
		aNivel := aTdaNiveis[nZ] 		
		
		//deletar a procedure de nivel superior correspondente ao cubo
		If Len(aNivel) > 0
			For nX := 1 TO Len(aNivel)
				If Len(aNivel[nX]) > 0
					cProcSup := aNivel[nX,3]
					If TCSPExist(cProcSup)
						cExecDrop := "Drop procedure "+cProcSup
						nRetDrop := TcSqlExec(cExecDrop)
						If nRetDrop <> 0
							MsgAlert(STR0025+cProcSup +STR0026)//"Erro na exclusao da Procedure: "###". Excluir manualmente no banco"
						Endif
					EndIf
					If !Empty(aNivel[nX,2])  //apagar arquivo temporario que era utilizado pela procedure
						MsErase(aNivel[nX,2])
					EndIf					
				EndIf
			Next nX
		EndIf
			
	Next nZ
	
EndIf

Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³P122CallProcºAutor  ³Microsiga           º Data ³  04/24/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcão responsavel pela chamada das procedures.               º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PCOA122                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function P122CallProc(aNivel, cPlanRev, cPlanVers, cItemProc, cSinal)           

Local cArqTemp 	:= "" 
Local nProx 	:= 1
Local aProc   	:= {}
Local aProcAKT	:= {}  // Tantos qtos forem os n'iveis do CUbo
Local cArqTrb
Local cArq  	:= ""
Local lRet		:= .T.
Local aResult	:= {}
Local cExec  	:= ""
Local cRet   	:= ""
Local iX      	:= 0

/* ---------------------------------------------------------------------------------------------------------------------
   Versão          - <v> Protheus 9.12 </v>
   Assinatura      - <a> 001 </a>
   Fonte Microsiga - <s> PCOA122.PRX </s>
   Descricao       - <d> Reprocessamento de Saldos - Cubos </d>
   Funcao do Siga  -     PCOA122Sld()
   -----------------------------------------------------------------------------------------------------------------
   Entrada         -  <ri> @IN_FILIALR	- Filial corrente 
       				   		@IN_CONFIG  - Codigo do cubo
         						@IN_FK      - '1' se integridade estiver ligada	</ri>
   -----------------------------------------------------------------------------------------------------------------
   Saida          -  <ro> @OUT_RESULT    -  </ro>
   -----------------------------------------------------------------------------------------------------------------
   Responsavel    -   <r> Alice Yaeko Yamamoto  </r>
   -----------------------------------------------------------------------------------------------------------------
   Data           -  <dt> 08/05/2008 </dt>
   Estrutura de chamadas
   ========= == ========
   Obs.: Não remova os tags acima. Os tags são a base para a geração automática, de documentação, pelo Parse.
   
   1 - excluir os movimentos diários do periodo do AKT
   3 - Iniciar Reprocessamento
      3.1 - Gerar todo o AKT do periodo através do AKD

/*   Ordem de chamada das procedures - Ordem de criacao de procedures 
  **  0.1.A300LastDay  - Retorna o ultimo dia do Mes .LASTDAY.................... 1  aProc[1]
  **  0.2.CallXFilial  - Xfilial ................................................ 2  aProc[2]
  	
   1.PCOA122Proc - Proc  pai .................................................... 5  aProc[5]
	1.1 PCOA122B - Atualiza uma analitica ou sintetica do AKT ................... 3  aProc[3]
   	1.2 PCOA122A - Atualiza os slds sintéticos (superiores) do AKT .............. 4  aProc[4] -> Loop no array aNivel
   --------------------------------------------------------------------------------------------------------------------- */
cArqTrb := CriaTrab(,.F.)
cArq    := cArqTRB+StrZero(nProx,2)
AADD( aProc, cArq+"_"+cEmpAnt)
lRet    := A122LastDay( cArq )   // A122LastDay aProc[1]

If lRet
	nProx   := nProx + 1
	cArq    := cArqTRB+StrZero(nProx,2)
	cArqAKT := cArq
	AADD( aProc, cArq+"_"+cEmpAnt)
	lRet    := CallXFilial( cArq )  // CallXfilial aProc[2]
EndIf  
If lRet
	/*Cria Procedure de atualizacao do AKT, cArq
	  cArq = SC999901  Nome da procedure */
	nProx := nProx + 1
	cArq    := cArqTRB+StrZero(nProx,2)
	cArqAKT := cArq
	AADD( aProc, cArq+"_"+cEmpAnt)           // PCOA122G  aProc[3]
	lRet    := PCOA122B(AL1->AL1_CONFIG, cArq, aProc)
EndIf
If lRet
	//Cria Procedure que faz chamada das atualizacoes de saldo no AKT
	nProx:= nProx+1
	cArq := cArqTrb+StrZero(nProx,2)
	AADD( aProc, cArq+"_"+cEmpAnt)
	lRet := PCOA122A(AL1->AL1_CONFIG, aNivel, cArq, cArqAKT, @aProcAKT)   //  PCOA122A  aproc[4]
EndIf
If lRet
	//Cria Procedure que faz chamada das atualizacoes de saldo
	nProx:= nProx+1
	cArq := cArqTrb+StrZero(nProx,2)
	AADD( aProc, cArq+"_"+cEmpAnt)
	lRet := PCOA122Proc( AL1->AL1_CONFIG, aNivel, cArq, aProc, aProcAKT, cItemProc, cSinal)   //  aProc[5]
EndIf
If lRet
	aResult := TCSPExec( xProcedures(cArq), cFilAnt, AL1->AL1_CONFIG, If(__lFKInUse, "1", "0"), cPlanRev, cPlanVers)
	TcRefresh(RetSqlName("AKT"))
	If Empty(aResult) .Or. aResult[1] = "0"
		MsgAlert(tcsqlerror(),STR0024)  //"Erro no Reprocessamento de Cubos!"
		lRet := .F.	
	EndIf
EndIf
/* Procedures e tabelas a 'Dropar'
   Procedures - aProc[1],.., aProc[8] = Ordem de chamadas de procedures
			       aProcAKT[1],..,aProcAKT[n] = procedures de atual. Saldos do AKT para cada Nivel do Cubo
	 Tabelas   - aNivel[1][1],..aNivel[n][2]= tabela temporaria com as sinteticas p todos os niveis do cubo
					 cArqTemp
*/
For iX = 1 to Len(aProc)   // exclusao de aProc
	If TCSPExist(aProc[iX])
		cExec := "Drop procedure "+aProc[iX]
		cRet := TcSqlExec(cExec)
		If cRet <> 0
			MsgAlert(STR0025+aProc[iX] +STR0026)//"Erro na exclusao da Procedure: "###". Excluir manualmente no banco"
		Endif
	EndIf
Next iX
For ix := 1 to Len(aProcAKT)    // exclusao de aProcAKT
	If TCSPExist(aProcAKT[iX])
		cExec := "Drop procedure "+aProcAKT[iX]
		cRet := TcSqlExec(cExec)
		If cRet <> 0
			MsgAlert(STR0025+aProcAKT[iX] +STR0026) //"Erro na exclusao da Procedure: "###". Excluir manualmente no banco"
		Endif
	EndIf
Next iX
If TcCanOpen(cArqTemp)   // exclusao de cArqTemp 
	If !TcDelFile(cArqTemp)
		MsgAlert(STR0027+cArqTemp+STR0028)  //"Erro na exclusao da Tabela: "###". Excluir manualmente"
	Endif
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A122LastDay³ Autor ³ Alice Yaeko Yamamoto  ³ Data ³06.06.08  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria  procedure que retorna o ultimo dia do mes              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A122LastDay( cArq )
Local aSaveArea := GetArea()
Local cQuery := ""
Local cProc  := cArq+"_"+cEmpAnt
Local lRet   := .T.

cQuery :="create procedure "+cProc+CRLF
cQuery+="   ( "+CRLF
cQuery+="   @IN_DATA  Char( 08 ),"+CRLF
cQuery+="   @OUT_DATA Char( 08 ) OutPut"+CRLF
cQuery+="   )"+CRLF
cQuery+="as"+CRLF

cQuery+="Declare @cData    VarChar( 08 )"+CRLF
cQuery+="Declare @iAno     Float"+CRLF
cQuery+="Declare @iResto   Float"+CRLF
cQuery+="Declare @iPos     Integer"+CRLF
cQuery+="Declare @cResto   VarChar( 10 )"+CRLF

cQuery+="begin"+CRLF
cQuery+="   Select @OUT_DATA = ' '"+CRLF
cQuery+="   Select @cData  = Substring( @IN_DATA, 5, 2 )"+CRLF//  -- MES
cQuery+="   select @iAno   = 0"+CRLF
cQuery+="   select @iResto = 0"+CRLF
cQuery+="   Select @iPos   = 0"+CRLF
cQuery+="   select @cResto = ''"+CRLF
   
   /* --------------------------------------------------------------
      Ultimo dia do periodo 
      -------------------------------------------------------------- */
cQuery+="   If @cData IN ( '01', '03', '05', '07', '08','10','12' ) begin"+CRLF
cQuery+="      select @cData = Substring( @IN_DATA, 1, 6 )||'31'"+CRLF
cQuery+="   end else begin"+CRLF
cQuery+="      If @cData = '02' begin"+CRLF
cQuery+="         Select @iAno = Convert( Float, Substring(@IN_DATA, 1,4) )"+CRLF
cQuery+="         Select @iResto = @iAno/4"+CRLF
cQuery+="         Select @cResto = Convert( varchar(10), @iResto )"+CRLF
         /* --------------------------------------------------------------
            nao existe '.' no @cResto , o nro é inteiro, divisivel por 4
            O ano deve ser múltiplo de 100, ou seja, divisível por 400
            -------------------------------------------------------------- */
cQuery+="         Select @iPos   = Charindex( '.', @cResto )"+CRLF
cQuery+="         If @iPos = 0 begin"+CRLF
cQuery+="            select @cData = Substring( @IN_DATA, 1, 6 )||'29'"+CRLF
cQuery+="            If @iAno in ( 2100, 2200, 2300, 2500 ) begin"+CRLF  // -- ANOS NAO DIVISÍVEIS POR 400
cQuery+="               select @cData = Substring( @IN_DATA, 1, 6 )||'28'"+CRLF
cQuery+="            End"+CRLF
cQuery+="         end else begin"+CRLF
cQuery+="            select @cData = Substring( @IN_DATA, 1, 6 )||'28'"+CRLF
cQuery+="         end"+CRLF
cQuery+="      end else begin"+CRLF
cQuery+="         select @cData = Substring( @IN_DATA, 1, 6 )||'30'"+CRLF
cQuery+="      End"+CRLF
cQuery+="   End"+CRLF
cQuery+="   Select @OUT_DATA = @cData"+CRLF
cQuery+="End"+CRLF

cQuery := MsParse(cQuery,If(Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB())))
If Upper(TcSrvType())= "ISERIES" .and. !Empty( cQuery )
	cQuery := pVldDb2400( cQuery )
EndIf

If Empty( cQuery )
	MsgAlert(MsParseError(),STR0029+cProc) //'A query nao passou pelo Parse '
	lRet := .F.
Else
	If !TCSPExist( cProc )
		cRet := TcSqlExec(cQuery)
		If cRet <> 0
			If !__lBlind
				MsgAlert(STR0030+cProc) //'Erro na criacao da procedure '
				lRet:= .F.
			EndIf
		EndIf
	EndIf
EndIf
RestArea(aSaveArea)
Return (lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PCOA122B   ³ Autor ³ Alice Yaeko Yamamoto  ³ Data ³13.06.08  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria as procedures de atualizacao do AKT                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PCOA122B( cCubo,cArq )                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso     ³ SigaPCO                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Par„metros³ ExpC1 = cCubo - Codigo do Cubo a ser atualizado             ³±±
±±³          ³ ExpC2 = cArq  - Nome da procedure q sera criada no banco    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/         
Function PCOA122B(cCubo, cArq, aProc )
Local aSaveArea  := GetArea()
Local cQuery     := ""
Local cQueryAux  := ""
Local cTipo      := ""
Local nPos       := 0
Local aCampos    := AKT->(DbStruct())
Local nPTratRec  := 0
Local nPosFim    := 0
Local nPosFim2   := 0 
Local nPos3      := 0
Local cProc      := cArq+"_"+cEmpAnt
Local lRet       := .T.
Local cTabela    := RetSqlName("AKT")
Local nRet       := 0
Local nCnt01     := 0

cQuery :="create procedure "+cProc+CRLF
cQuery +="( "+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "AKT_FILIAL" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery +="	@IN_FILIALCOR	"+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "AKT_CONFIG" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery +="	@IN_CONFIG    	"+cTipo+CRLF
cQuery +="	@IN_DATA    	Char(08),"+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "AKT_CHAVE" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery +="	@IN_CHAVE      "+cTipo+CRLF
cQuery +="	@IN_VALORD1   	float,"+CRLF
cQuery +="	@IN_VALORD2  	float,"+CRLF
cQuery +="	@IN_VALORD3  	float,"+CRLF
cQuery +="	@IN_VALORD4  	float,"+CRLF
cQuery +="	@IN_VALORD5  	float,"+CRLF
cQuery +="	@IN_VALORC1   	float,"+CRLF
cQuery +="	@IN_VALORC2  	float,"+CRLF
cQuery +="	@IN_VALORC3  	float,"+CRLF
cQuery +="	@IN_VALORC4  	float,"+CRLF
cQuery +="	@IN_VALORC5  	float,"+CRLF
DbSelectArea("AKW")
DbSetOrder(1)
DbSeek( xFilial("AKW")+cCubo)
While xFilial("AKW")+AKW->AKW_COD = xFilial("AKW")+cCubo .and. !Eof()
	cQueryAux :=cQueryAux+"   @IN_NIV"+Trim(AKW->AKW_NIVEL)+"      Char( "+StrZero(AKW->AKW_TAMANH,02)+" ),"+CRLF  // CONTA
	dbSkip()
EndDo  
/* Tirar a virgula do final*/
cQueryAux := SubString(cQueryAux,1, (Len(cQueryAux)-3))
cQuery +=cQueryAux+CRLF
cQuery +=")"+CRLF
cQuery +="as"+CRLF
/* ---------------------------------------------------------------------------------------------------------------------
    Versão          - <v> Protheus 8.11 </v>
    Assinatura      - <a> 001 </a>
    Fonte Microsiga - <s> PCOA122 </s>
    Descricao       - <d> Atualiza os saldos do AKT  </d>
    Funcao do Siga  -     PcoWriteSld()
    -----------------------------------------------------------------------------------------------------------------
    Entrada         -  <ri> @IN_FILIALCOR	- Filial corrente 
       				   		@IN_CONFIG    	- Codigo do cubo
         						@IN_DATA    	- Ultimo dia do mes da data do movimento
         						@IN_CHAVE  		- Chave do cubo
         						@IN_VALOR1   	- Valor na moeda 1
         						@IN_VALOR2   	- Valor na moeda 2
         						@IN_VALOR3   	- Valor na moeda 3
         						@IN_VALOR4   	- Valor na moeda 4
         						@IN_VALOR5   	- Valor na moeda 5	</ri>
    -----------------------------------------------------------------------------------------------------------------
    Saida       :  <ro> Sem saida </ro>
    -----------------------------------------------------------------------------------------------------------------
    Versão      :  <v> Advanced Protheus </v>
    -----------------------------------------------------------------------------------------------------------------
    Observações :  <o>   </o>
    -----------------------------------------------------------------------------------------------------------------
    Responsavel :   <r> Alice Yaeko Yamamoto  </r>
    -----------------------------------------------------------------------------------------------------------------
    Data        :  <dt> 29/04/2008 </dt>

    Estrutura de chamadas
    ========= == ========
   --------------------------------------------------------------------------------------------------------------------- */
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "AKT_FILIAL" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery +="Declare @cFil_AKT   "+cTipo+CRLF
cQuery +="Declare @cAux       Char(03)"+CRLF
cQuery +="Declare @iRecnoAKT  Integer"+CRLF
cQuery +="Declare @nValorD1   Float"+CRLF
cQuery +="Declare @nValorD2   Float"+CRLF
cQuery +="Declare @nValorD3   Float"+CRLF
cQuery +="Declare @nValorD4   Float"+CRLF
cQuery +="Declare @nValorD5   Float"+CRLF
cQuery +="Declare @nValorC1   Float"+CRLF
cQuery +="Declare @nValorC2   Float"+CRLF
cQuery +="Declare @nValorC3   Float"+CRLF
cQuery +="Declare @nValorC4   Float"+CRLF
cQuery +="Declare @nValorC5   Float"+CRLF
cQuery +=""+CRLF
// Insere tratamento para xfilial dentro do codigo 
cQuery +="begin"+CRLF
   /* --------------------------------------------------------------
      Recuperando Filiais
      -------------------------------------------------------------- */
cQuery +="   select @cAux = 'AKT'"+CRLF
cQuery +="   EXEC "+aProc[2]+" @cAux, @IN_FILIALCOR, @cFil_AKT OutPut "+CRLF
   
cQuery +="   select @nValorD1 = @IN_VALORD1"+CRLF
cQuery +="   select @nValorD2 = @IN_VALORD2"+CRLF
cQuery +="   select @nValorD3 = @IN_VALORD3"+CRLF
cQuery +="   select @nValorD4 = @IN_VALORD4"+CRLF
cQuery +="   select @nValorD5 = @IN_VALORD5"+CRLF
cQuery +="   select @nValorC1 = @IN_VALORC1"+CRLF
cQuery +="   select @nValorC2 = @IN_VALORC2"+CRLF
cQuery +="   select @nValorC3 = @IN_VALORC3"+CRLF
cQuery +="   select @nValorC4 = @IN_VALORC4"+CRLF
cQuery +="   select @nValorC5 = @IN_VALORC5"+CRLF
cQuery +="   select @iRecnoAKT = null"+CRLF
   /* --------------------------------------------------------------
      Atualizacao de Credito do dia - AKT
      -------------------------------------------------------------- */
cQuery +="   Select @iRecnoAKT = R_E_C_N_O_"+CRLF
cQuery +="     From "+cTabela+CRLF
cQuery +="    where AKT_FILIAL = @cFil_AKT"+CRLF
cQuery +="		and AKT_CONFIG = @IN_CONFIG"+CRLF
cQuery +="		and AKT_CHAVE  = @IN_CHAVE"+CRLF
cQuery +="		and AKT_DATA	= @IN_DATA"+CRLF
cQuery +="     and D_E_L_E_T_ = ' '"+CRLF
   
cQuery +="   begin tran"+CRLF
cQuery +="   If @iRecnoAKT Is Null begin"+CRLF
cQuery +="      select @iRecnoAKT = IsNull(Max(R_E_C_N_O_), 0) FROM "+RetSqlName("AKT")+CRLF
cQuery +="      select @iRecnoAKT = @iRecnoAKT + 1"+CRLF
cQuery +="      ##TRATARECNO @iRecnoAKT\"+CRLF
cQuery +="      insert into "+cTabela+" (	AKT_FILIAL, AKT_CHAVE,  AKT_DATA,   AKT_CONFIG, AKT_MVCRD1, AKT_MVCRD2, AKT_MVCRD3, AKT_MVCRD4, AKT_MVCRD5,"+CRLF
DbSelectArea("AKW")
DbSetOrder(1)                                                               
DbSeek( xFilial("AKW")+cCubo)
cQueryAux := ""
While xFilial("AKW")+AKW->AKW_COD = xFilial("AKW")+cCubo .and. !Eof()
	If Trim(Substring(AKW->AKW_CHAVER, 9, Len(AKW->AKW_CHAVER))) = "_TPSALD"
		cQueryAux :=cQueryAux+"AKT_TPSALD, "
	Else
		cQueryAux :=cQueryAux+"AKT_NIV"+Trim(AKW->AKW_NIVEL)+","+"  "
	EndIf
	dbSkip()
EndDo
//AKT_NIV01,  AKT_NIV02,  AKT_TPSALD, R_E_C_N_O_ )"+CRLF
cQuery +="                           AKT_MVDEB1, AKT_MVDEB2, AKT_MVDEB3, AKT_MVDEB4, AKT_MVDEB5, "+cQueryAux/*AKT_NIV01,  AKT_NIV02,  AKT_TPSALD, */
cQuery +=" R_E_C_N_O_ )"+CRLF
cQuery +="                   values( @cFil_AKT,  @IN_CHAVE,  @IN_DATA,   @IN_CONFIG, @nValorC1,  @nValorC2,  @nValorC3,  @nValorC4,  @nValorC5,"+CRLF
cQuery +="                           @nValorD1,  @nValorD2,  @nValorD3,  @nValorD4,  @nValorD5,  "
DbSelectArea("AKW")
DbSetOrder(1)                                                               
DbSeek( xFilial("AKW")+cCubo)
cQueryAux := ""
While xFilial("AKW")+AKW->AKW_COD = xFilial("AKW")+cCubo .and. !Eof()
	cQueryAux :=cQueryAux+"@IN_NIV"+Trim(AKW->AKW_NIVEL)+","+"  "
	dbSkip()
EndDo
cQuery +=cQueryAux+"@iRecnoAKT )"+CRLF
cQuery +="      ##FIMTRATARECNO"+CRLF
cQuery +="   end else begin"+CRLF
cQuery +="      Update "+cTabela+CRLF
cQuery +="         Set AKT_MVCRD1 = AKT_MVCRD1 + @nValorC1, AKT_MVCRD2 = AKT_MVCRD2 + @nValorC2, AKT_MVCRD3 = AKT_MVCRD3 + @nValorC3,"+CRLF
cQuery +="             AKT_MVCRD4 = AKT_MVCRD4 + @nValorC4, AKT_MVCRD5 = AKT_MVCRD5 + @nValorC5, AKT_MVDEB1 = AKT_MVDEB1 + @nValorD1,"+CRLF
cQuery +="             AKT_MVDEB2 = AKT_MVDEB2 + @nValorD2, AKT_MVDEB3 = AKT_MVDEB3 + @nValorD3, AKT_MVDEB4 = AKT_MVDEB4 + @nValorD4,"+CRLF
cQuery +="             AKT_MVDEB5 = AKT_MVDEB5 + @nValorD5"+CRLF
cQuery +="       Where R_E_C_N_O_ = @iRecnoAKT"+CRLF
cQuery +="   End"+CRLF
cQuery +="   commit tran"+CRLF
cQuery +="end"+CRLF

cQuery := CtbAjustaP(.T., cQuery, @nPTratRec)
cQuery := MsParse(cQuery,If(Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB())))
cQuery := CtbAjustaP(.F., cQuery, nPTratRec)

If !TCSPExist( cProc )
	nRet := TcSqlExec(cQuery)
	If nRet <> 0 
		If !__lBlind
			MsgAlert(STR0031+cProc) //'Erro na criacao da procedure de atualizacao do AKT'
			lRet:= .F.
		EndIf
	EndIf
EndIf

RestArea(aSaveArea)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PCOA122A   ³ Autor ³                       ³ Data ³19.06.13  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria  procedures p atualizacao do AKT para os niveis superio-³±±
±±³          ³res (sintéticas) do Cubo                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PCOOA122E(cCubo,aNivel, cArq,cArqAKT, aProcAKT )            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso     ³ SigaPCO                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Par„metros³ ExpC1 = cCubo -  Codigo do Cubo a ser atualizado            ³±±
±±³          ³ ExpA2 = aNivel-  Niveis a serem atualizados                 ³±±
±±³          ³ ExpC2 = cArq  -  Nome da procedure q sera criada no banco   ³±±
±±³          ³ ExpC2 = cArqAKT- Nome da procedure de At. do AKT            ³±±
±±³          ³ ExpC2 = aProcAKT-Nome da procedure de At. do AKT            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCOA122A(cCubo, aNivel, cArq, cArqAKT, aProcAKT)
Local aSaveArea := GetArea()
Local cQuery    := ""
Local cQueryAux := ""
Local cTipo     := ""
Local nPos      := 0
Local iX        := 0
Local iNivel    := 0
Local aCampos   := AKT->(DbStruct())
Local cProc     := cArq
Local cProcAKT  := cArqAKT+"_"+cEmpAnt
Local lRet      := .T. 
/*  aNivel[1][1] = AK5 ou CT1 -> Alias do Nivel
	aNivel[1][2] = SC999999   -> Tabela temporaria
	aNivel[1][3] = Nome da procedure superior
	aNivel[1][4] = Nivel do cubo em q sls superiores serão gerados
*/
For iX := 1 to Len(aNivel)
	cQuery := ""
	cQuery:="Create Procedure "+cProc+StrZero(iX, 2)+"_"+cEmpAnt+" ("+CRLF
	nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "AKT_FILIAL" } )
	cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
	cQuery+="	@IN_FILIAL     "+cTipo+CRLF
	nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "AKT_CONFIG" } )
	cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
	cQuery +="	@IN_CONFIG    	"+cTipo+CRLF
	cQuery+="	@IN_DATA    	Char( 08 ),"+CRLF
	cQuery+="	@IN_VALORD1  	float,"+CRLF
	cQuery+="	@IN_VALORD2  	float,"+CRLF
	cQuery+="	@IN_VALORD3  	float,"+CRLF
	cQuery+="	@IN_VALORD4  	float,"+CRLF
	cQuery+="	@IN_VALORD5  	float,"+CRLF
	cQuery+="	@IN_VALORC1   	float,"+CRLF
	cQuery+="	@IN_VALORC2   	float,"+CRLF
	cQuery+="	@IN_VALORC3   	float,"+CRLF
	cQuery+="	@IN_VALORC4   	float,"+CRLF
	cQuery+="	@IN_VALORC5   	float,"+CRLF
	cQueryAux:= ""
	DbSelectArea("AKW")
	DbSetOrder(1)
	DbSeek( xFilial("AKW")+cCubo)
	While xFilial("AKW")+AKW->AKW_COD = xFilial("AKW")+cCubo .and. !Eof()
		cQueryAux :=cQueryAux+"       @IN_NIV"+Trim(AKW->AKW_NIVEL)+"      Char( "+StrZero(AKW->AKW_TAMANH,02)+" ),"+CRLF  // CONTA
		dbSkip()
	EndDo
	/* Tirar a virgula do final*/
	cQueryAux := SubString(cQueryAux,1, (Len(cQueryAux)-3))
	cQuery +=cQueryAux+CRLF
	cQuery+=")"+CRLF
	
	cQuery+="as"+CRLF
	DbSelectArea("AKW")
	DbSetOrder(1)
	dbSeek(xFilial("AKW")+cCubo+aNivel[ix][4])
	cQuery+="Declare @cAnalitica    Char( "+StrZero(AKW->AKW_TAMANH,02)+" )"+CRLF
	cQuery+="Declare @cSuperior     Char( "+StrZero(AKW->AKW_TAMANH,02)+" )"+CRLF
	
	nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "AKT_CHAVE" } )
	cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
	cQuery+="Declare @cChaveR "+cTipo+CRLF

	cQuery+="begin"+CRLF
	cQuery+="   select @cChaveR = ''"+CRLF
	cQuery+="   Declare CUR_AKT"+aNivel[iX][1]+"NIV"+aNivel[iX][4]+" insensitive cursor for"+CRLF
	cQuery+="   select ANALITICA, SUPERIOR"+CRLF
	cQuery+="     from "+aNivel[iX][2]+" "+CRLF   // tabela temporária
	cQuery+="    where ANALITICA = @IN_NIV"+aNivel[iX][4]+CRLF  
	cQuery+="   for read only"+CRLF
	cQuery+="   Open CUR_AKT"+aNivel[iX][1]+"NIV"+aNivel[iX][4]+CRLF
	cQuery+="   Fetch CUR_AKT"+aNivel[iX][1]+"NIV"+aNivel[iX][4]+" into @cAnalitica, @cSuperior"+CRLF
	
	cQuery+="   While @@fetch_status = 0 begin"+CRLF
	/* Atualizo as superiores
		ak5 = 111002 -> analitica       CTT = 112 ->  analitica                                                                                   
				111    -> 1 superior            11  -> 1 superior 
				11     -> 2 superior            1   -> 2 superior 
				1		 -> 3 superior 
		No caso de termos AK5 =  nivel01 e CTT = nivel02 Tipo de Saldo = PR,
		as Analiticas do nivel01 e a analitica do nivel2 sao as mesmas = 111002 112 PR
	    */
	DbSelectArea("AKW")
	DbSetOrder(1)
	DbSeek( xFilial("AKW")+cCubo)
	cQueryAux:=""
	cQueryAux+="      Select @cChaveR = "
	While xFilial("AKW")+AKW->AKW_COD = xFilial("AKW")+cCubo .and. !Eof()
		cQueryAux += IIf(AKW->AKW_NIVEL=aNivel[ix][4]," @cSuperior||","@IN_NIV"+AKW->AKW_NIVEL+"||" )
		dbSkip()
	EndDo
	/* Tirar || do final */
	cQueryAux := SubString(cQueryAux,1, (Len(cQueryAux)-2))
	cQuery +=cQueryAux+CRLF
	      /* --------------------------------------------------------------
	         Inicia o Atualizacao do AKT
	         -------------------------------------------------------------- */
	cQuery+="      EXEC "+cProcAKT+" @IN_FILIAL,  @IN_CONFIG,  @IN_DATA,    @cChaveR,    @IN_VALORD1, @IN_VALORD2, @IN_VALORD3, @IN_VALORD4, @IN_VALORD5,"+CRLF
	cQuery+="                       @IN_VALORC1, @IN_VALORC2, @IN_VALORC3, @IN_VALORC4, @IN_VALORC5,"
	cQueryAux:= ""
	DbSelectArea("AKW")
	DbSetOrder(1)
	DbSeek( xFilial("AKW")+cCubo)
	While xFilial("AKW")+AKW->AKW_COD = xFilial("AKW")+cCubo .and. !Eof()
		cQueryAux += IIf(AKW->AKW_NIVEL=aNivel[iX][4]," @cSuperior,"," @IN_NIV"+AKW->AKW_NIVEL+"," )
		dbSkip()
	EndDo
	/* Tirar , do final */
	cQueryAux := SubString(cQueryAux,1, (Len(cQueryAux)-1))
	cQuery +=cQueryAux+CRLF
	cQuery+="      Fetch CUR_AKT"+aNivel[iX][1]+"NIV"+aNivel[iX][4]+" into @cAnalitica, @cSuperior"+CRLF
	cQuery+="   End"+CRLF
	cQuery+="   Close CUR_AKT"+aNivel[iX][1]+"NIV"+aNivel[iX][4]+CRLF
	cQuery+="   Deallocate CUR_AKT"+aNivel[iX][1]+"NIV"+aNivel[iX][4]+CRLF
	cQuery+="End"+CRLF
	
	cQuery := MsParse(cQuery,If(Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB())))
	cQuery := CtbAjustaP(.F., cQuery, 0)	
	If Empty( cQuery )
		MsgAlert(MsParseError(),STR0034+aNivel[ix][1]+"-"+aNivel[iX][4]+"-"+cProc)//'A query de Atual. Slds de Ctas Superiores  nao passou pelo Parse '
		lRet := .F.
	Else
		If !TCSPExist( cProc )
			cRet := TcSqlExec(cQuery)
			AADD( aProcAKT, cProc+StrZero(iX, 2)+"_"+cEmpAnt )
			If cRet <> 0
				If !__lBlind
					MsgAlert(STR0035+aNivel[ix][1]+"-"+aNivel[iX][4]+"-"+cProc)  //"Erro na criacao da proc de Atual. Slds de Ctas Superiores Nivel: "
					lRet:= .F.
					Exit
				EndIf
			EndIf
		EndIf
	EndIf
Next iX

RestArea(aSaveArea)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PCOA122Proc³ Autor ³ Alice Yaeko Yamamoto    ³ Data ³06.06.08  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria  procedures Pai                                           ³±±
±±³          ³                                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso     ³ SigaPCO                                                       ³±±
2±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Par„metros³ExpC1 = cCubo    - Codigo do Cubo a ser atualizado             ³±±
±±³          ³ExpA1 = aNivel   - Niveis a serem atualizados                  ³±±
±±³          ³ExpC2 = cArq     - Nome da procedure q sera criada no banco    ³±±
±±³          ³ExpA1 = aProc    - Array c procedures                          ³±±
±±³          ³ExpA2 = aProcAKT - Array com as procedures criadas p niveis AKT³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCOA122Proc( cCubo, aNivel, cArq, aProc, aProcAKT, cItemProc, cSinal)
Local aSaveArea := GetArea()
Local cQuery    := ""
Local cQueryAux := ""
Local cTipo     := ""
Local nPos      := 0
Local iX        := 0
Local iZ        := 0
Local iNivel    := 0
Local aCampos   := AKT->(DbStruct())
Local aCampos1  := AKD->(DbStruct())
Local aCposAux, cVarAux, nZ
Local cProc     := cArq+"_"+cEmpAnt
Local lREt      := .T.
Local iProc     := 0

cQuery:="Create Procedure "+cProc+"("+CRLF 
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "AKT_FILIAL" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery+="   @IN_FILIAL  "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "AKT_CONFIG" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery+="   @IN_CONFIG  "+cTipo+CRLF
cQuery+="   @IN_FK      Char( 01 ),"+CRLF
nPos := Ascan( aCampos1, {|x| Alltrim(x[1]) == "AKD_CODPLA" } )
cTipo := " Char( "+StrZero(aCampos1[nPos][3],3)+" ),"
cQuery+="   @IN_CODPLA  "+cTipo+CRLF
nPos := Ascan( aCampos1, {|x| Alltrim(x[1]) == "AKD_VERSAO" } )
cTipo := " Char( "+StrZero(aCampos1[nPos][3],3)+" ),"
cQuery+="   @IN_NEWVER  "+cTipo+CRLF
cTipo := " Char( "+StrZero(aCampos1[nPos][3],3)+" ),"
cQuery+="   @OUT_RESULT Char( 01) OutPut"+CRLF
cQuery+=")"+CRLF
cQuery+="as"+CRLF
/* ---------------------------------------------------------------------------------------------------------------------
   Versão          - <v> Protheus 9.12 </v>
   Assinatura      - <a> 001 </a>
   Fonte Microsiga - <s> PCOA122.PRX </s>
   Descricao       - <d> Reprocessamento de Saldos - Cubos </d>
   Funcao do Siga  -     PCOA122Sld()
   -----------------------------------------------------------------------------------------------------------------
   Entrada         -  <ri> @IN_FILIALR	- Filial corrente 
       				   		@IN_CONFIG  - Codigo do cubo
         						@IN_FK      - '1' se integridade estiver ligada	</ri>
   -----------------------------------------------------------------------------------------------------------------
   Saida          -  <ro> @OUT_RESULT    -  </ro>
   -----------------------------------------------------------------------------------------------------------------
   Responsavel    -   <r> Alice Yaeko Yamamoto  </r>
   -----------------------------------------------------------------------------------------------------------------
   Data           -  <dt> 08/05/2008 </dt>
   Estrutura de chamadas
   ========= == ========
   Obs.: Não remova os tags acima. Os tags são a base para a geração automática, de documentação, pelo Parse.
   
   3 - Iniciar Reprocessamento
      3.1 - Gerar todo o AKT do periodo através do AKD
            
/*   Ordem de chamada das procedures - Ordem de criacao de procedures
  **  0.1.A300LastDay  - Retorna o ultimo dia do Mes .LASTDAY.................... 1  aProc[1]
  **  0.2.CallXFilial  - Xfilial ................................................ 2  aProc[2]

   1.PCOA122Proc - Proc  pai .............................................. 5  aProc[5]
	1.1 PCOA122B - Atualiza uma analitica do AKT .......................... 3  aProc[3]
   	1.2 PCOA122A - Atualiza os slds sintéticos (superiores) do AKT ........ 4  aProc[4]  While no array aNivel
   --------------------------------------------------------------------------------------------------------------------- */
cQuery+="Declare @cAux        Char( 03 )"+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "AKT_FILIAL" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="Declare @cFil_AKD    "+cTipo+CRLF
cQuery+="Declare @cFil_AK2    "+cTipo+CRLF
cQuery+="Declare @cFilial     "+cTipo+CRLF
cQuery+="Declare @cFilAnt     "+cTipo+CRLF
nPos := Ascan( aCampos1, {|x| Alltrim(x[1]) == "AKD_TIPO" } )
cTipo := " Char( "+StrZero(aCampos1[nPos][3],3)+" )"
cQuery+="Declare @cAKD_TIPO   "+cTipo+CRLF
cQuery+="Declare @cAKD_DATA   Char( 08 )"+CRLF
cQuery+="Declare @cDataAnt    Char( 08 )"+CRLF
/* mais campos a serem criados run time - olhar oos Níveis do Cubo */ 
DbSelectArea("AKW")
DbSetOrder(1)
DbSeek( xFilial("AKW")+cCubo)
cQueryAux := ""
While xFilial("AKW")+AKW->AKW_COD = xFilial("AKW")+cCubo .and. !Eof()
	aCposAux	:=	Str2Arr( Alltrim(AKW->AKW_CHAVER) , "+")  //quebra em array por delimitador "+"
	If Len(aCposAux) == 1
		cQueryAux +="Declare @c"+Trim(Substring(AKW->AKW_CHAVER,6,Len(AKW->AKW_CHAVER)))+" Char( "+StrZero(AKW->AKW_TAMANH,2)+" )"+CRLF
		cQueryAux +="Declare @c"+Trim(Substring(AKW->AKW_CHAVER,6,Len(AKW->AKW_CHAVER)))+"Ant"+" Char( "+StrZero(AKW->AKW_TAMANH,2)+" )"+CRLF
	Else
		For nZ := 1 TO Len(aCposAux)
			cVarAux := Alltrim(StrTran(aCposAux[nZ], "AKD->", ""))
			cQueryAux +="Declare @c"+cVarAux+" Char( "+StrZero(TamSx3(cVarAux)[1] ,2)+" )"+CRLF
			cQueryAux +="Declare @c"+cVarAux+"Ant"+" Char( "+StrZero(TamSx3(cVarAux)[1],2)+" )"+CRLF
		Next	
  		cQueryAux +="Declare @c"+Alltrim(StrTran(aCposAux[1], "AKD->", ""))+"Aux  Char( "+StrZero(AKW->AKW_TAMANH,2)+" )"+CRLF
  		cQueryAux +="Declare @c"+Alltrim(StrTran(aCposAux[1], "AKD->", ""))+"AuxAnt Char( "+StrZero(AKW->AKW_TAMANH,2)+" )"+CRLF
	EndIf	
	dbSkip()
EndDo
cQuery+=cQueryAux
cQuery+="Declare @nAKD_VALOR1 Float"+CRLF
cQuery+="Declare @nAKD_VALOR2 Float"+CRLF
cQuery+="Declare @nAKD_VALOR3 Float"+CRLF
cQuery+="Declare @nAKD_VALOR4 Float"+CRLF
cQuery+="Declare @nAKD_VALOR5 Float"+CRLF
cQuery+="Declare @nTotDEB1    Float"+CRLF
cQuery+="Declare @nTotDEB2    Float"+CRLF
cQuery+="Declare @nTotDEB3    Float"+CRLF
cQuery+="Declare @nTotDEB4    Float"+CRLF
cQuery+="Declare @nTotDEB5    Float"+CRLF
cQuery+="Declare @nTotCRD1    Float"+CRLF
cQuery+="Declare @nTotCRD2    Float"+CRLF
cQuery+="Declare @nTotCRD3    Float"+CRLF
cQuery+="Declare @nTotCRD4    Float"+CRLF
cQuery+="Declare @nTotCRD5    Float"+CRLF
cQuery+="Declare @nValorD1    Float"+CRLF
cQuery+="Declare @nValorD2    Float"+CRLF
cQuery+="Declare @nValorD3    Float"+CRLF
cQuery+="Declare @nValorD4    Float"+CRLF
cQuery+="Declare @nValorD5    Float"+CRLF
cQuery+="Declare @nValorC1    Float"+CRLF
cQuery+="Declare @nValorC2    Float"+CRLF
cQuery+="Declare @nValorC3    Float"+CRLF
cQuery+="Declare @nValorC4    Float"+CRLF
cQuery+="Declare @nValorC5    Float"+CRLF
cQuery+="Declare @cDataDiario VarChar( 08 )"+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "AKT_CHAVE" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="Declare @cChaveAKT   "+cTipo+CRLF
cQuery+="Declare @cChaveR     "+cTipo+CRLF
cQuery+="Declare @cChave      "+cTipo+CRLF
cQuery+="Declare @cChave1     "+cTipo+CRLF
cQuery+="Declare @lAtuAKT Char( 01 )"+CRLF

cQuery+="Begin"+CRLF
cQuery+="   select @OUT_RESULT  = '0'"+CRLF
cQuery+="   select @nTotDEB1 = 0, @nTotDEB2 = 0, @nTotDEB3 = 0, @nTotDEB4 = 0, @nTotDEB5 = 0"+CRLF
cQuery+="   select @nTotCRD1 = 0, @nTotCRD2 = 0, @nTotCRD3 = 0, @nTotCRD4 = 0, @nTotCRD5 = 0"+CRLF
cQuery+="   select @cDataDiario = ''"+CRLF
cQuery+="   select @cChaveAKT   = ''"+CRLF
cQuery+="   select @cChaveR     = ''"+CRLF
cQuery+="   select @cChave      = ''"+CRLF
cQuery+="   select @cChave1     = ''"+CRLF
cQuery+="   select @cFil_AKD    = '  '"+CRLF
cQuery+="   select @cFil_AK2    = '  '"+CRLF
cQuery+="   select @nValorD1    = 0"+CRLF
cQuery+="   select @nValorD2    = 0"+CRLF
cQuery+="   select @nValorD3    = 0"+CRLF
cQuery+="   select @nValorD4    = 0"+CRLF
cQuery+="   select @nValorD5    = 0"+CRLF
cQuery+="   select @nValorC1    = 0"+CRLF
cQuery+="   select @nValorC2    = 0"+CRLF
cQuery+="   select @nValorC3    = 0"+CRLF
cQuery+="   select @nValorC4    = 0"+CRLF
cQuery+="   select @nValorC5    = 0"+CRLF
cQuery+="   select @lAtuAKT     = '0'"+CRLF
cQuery+="   select @cFilAnt     = '  '"+CRLF
cQuery+="   select @cDataAnt    = ''"+CRLF
DbSelectArea("AKW")
DbSetOrder(1)
DbSeek( xFilial("AKW")+cCubo)
cQueryAux := ""
While xFilial("AKW")+AKW->AKW_COD = xFilial("AKW")+cCubo .and. !Eof()
	aCposAux	:=	Str2Arr( Alltrim(AKW->AKW_CHAVER) , "+")  //quebra em array por delimitador "+"
	If Len(aCposAux) == 1
		cQueryAux +="   Select @c"+Trim(Substring(AKW->AKW_CHAVER,6,Len(AKW->AKW_CHAVER)))+"Ant"+" = ''"+CRLF	
	Else
		For nZ := 1 TO Len(aCposAux)
			cVarAux := Alltrim(StrTran(aCposAux[nZ], "AKD->", ""))
			cQueryAux +="   Select @c"+cVarAux+"Ant"+" = ''"+CRLF
		Next
  		cQueryAux +="   Select @c"+Alltrim(StrTran(aCposAux[1], "AKD->", ""))+"Aux    = ''"+CRLF
  		cQueryAux +="   Select @c"+Alltrim(StrTran(aCposAux[1], "AKD->", ""))+"AuxAnt = ''"+CRLF
	EndIf	
	dbSkip()
EndDo
cQuery+=cQueryAux
   /* --------------------------------------------------------------
      Recuperando Filiais
      -------------------------------------------------------------- */
cQuery+="   select @cAux = 'AKD'"+CRLF
cQuery+="   EXEC "+aProc[2]+" @cAux, @IN_FILIAL, @cFil_AKD OutPut"+CRLF
cQuery+="   select @cAux = 'AK2'"+CRLF
cQuery+="   EXEC "+aProc[2]+" @cAux, @IN_FILIAL, @cFil_AK2 OutPut"+CRLF
   /* --------------------------------------------------------------
      3 - Inicia o Reprocessamento no range informado
		Trazer o AKD agrupado por data e pela chave do cubo
      -------------------------------------------------------------- */
cQuery+="   Declare CUR_PCO122 insensitive cursor for"+CRLF      //- AL1->AL1_CHAVER, cQuery	+=	cCampos+" , "    //campos do cubo gerencial   
cQuery+="	Select AKD_FILIAL, AKD_TIPO, AKD_DATA, "
cQueryAux:=""
DbSelectArea("AKW")
DbSetOrder(1)
DbSeek( xFilial("AKW")+cCubo)
While xFilial("AKW")+AKW->AKW_COD = xFilial("AKW")+cCubo .and. !Eof()
	aCposAux	:=	Str2Arr( Alltrim(AKW->AKW_CHAVER) , "+")  //quebra em array por delimitador "+"
	If Len(aCposAux) == 1
		cQueryAux +=Trim(Substring(AKW->AKW_CHAVER,6,Len(AKW->AKW_RELAC)))+", "
		iNivel += 1
	Else
		For nZ := 1 TO Len(aCposAux)
			cVarAux := Alltrim(StrTran(aCposAux[nZ], "AKD->", ""))
			cQueryAux += cVarAux + ", " 
			iNivel += 1
		Next nZ	
	EndIf	
	dbSkip()
EndDo
cQuery+=cQueryAux
If cSinal = "+"
	cQuery+="SUM(AKD_VALOR1), SUM(AKD_VALOR2), SUM(AKD_VALOR3), SUM(AKD_VALOR4), SUM(AKD_VALOR5)"+CRLF
Else
	cQuery+="SUM(AKD_VALOR1)*-1, SUM(AKD_VALOR2)*-1, SUM(AKD_VALOR3)*-1, SUM(AKD_VALOR4)*-1, SUM(AKD_VALOR5)*-1"+CRLF
EndIf
cQuery+="    from "+RetSqlName("AKD")+CRLF
cQuery+="    where AKD_FILIAL = @cFil_AKD"+CRLF
cQuery+="      and AKD_STATUS = '1'"+CRLF
cQuery+="      and AKD_TIPO IN ( '1', '2' )"+CRLF
cQuery+="      and D_E_L_E_T_ = ' '"+CRLF
cQuery+="      and R_E_C_N_O_ IN ( select AKD.R_E_C_N_O_ From "+RetSqlName("AKD")+" AKD , "+RetSqlName("AK2")+" AK2"+CRLF
cQuery+="							where AKD_FILIAL = @cFil_AKD"+CRLF
cQuery+="							  and AKD_PROCES = '000252'"+CRLF
cQuery+="							  and AKD_ITEM   = '"+cItemProc+"'"+CRLF
cQuery+="                             and AKD_CHAVE  = 'AK2'||AK2_FILIAL||AK2_ORCAME||AK2_VERSAO||AK2_CO||AK2_PERIOD||AK2_ID"+CRLF // sempre fixo, indice 1 do AK2, POIS É PLANILHA
cQuery+="                             and AKD.D_E_L_E_T_ = ' '"+CRLF
cQuery+="                             and AK2_FILIAL = @cFil_AK2"+CRLF
cQuery+="		                      and AK2_ORCAME = @IN_CODPLA"+CRLF
cQuery+="		                      and AK2_VERSAO = @IN_NEWVER"+CRLF
cQuery+="                             and AK2.D_E_L_E_T_ = ' '"+CRLF
cQuery+="                             )"+CRLF
cQuery+="		group by AKD_FILIAL, AKD_TIPO, AKD_DATA,"  //, AKD_CO, AKD_CC, AKD_TPSALD
cQueryAux:=Substring(cQueryAux,1,(Len(cQueryAux)-2))
cQuery+= cQueryAux+CRLF
cQuery+="		order by 3"
For iZ = 1 to iNivel
	iX = 3 +	iZ
	cQuery+= ", "+Str(3+iZ)
Next iZ
cQuery+=CRLF
cQuery+="   for read only"+CRLF
cQuery+="   Open CUR_PCO122"+CRLF
cQuery+="   Fetch CUR_PCO122 into @cFilial, @cAKD_TIPO, @cAKD_DATA,"/*@cAKD_CO, @cAKD_CC, @cAKD_TPSALD*/
cQueryAux:=""
DbSelectArea("AKW")
DbSetOrder(1)
DbSeek( xFilial("AKW")+cCubo)
While xFilial("AKW")+AKW->AKW_COD = xFilial("AKW")+cCubo .and. !Eof()
	aCposAux	:=	Str2Arr( Alltrim(AKW->AKW_CHAVER) , "+")  //quebra em array por delimitador "+"
	If Len(aCposAux) == 1
		cQueryAux +="@c"+Trim(Substring(AKW->AKW_CHAVER,6,Len(AKW->AKW_RELAC)))+", "
	Else
		For nZ := 1 TO Len(aCposAux)
			cVarAux := Alltrim(StrTran(aCposAux[nZ], "AKD->", ""))
			cQueryAux +="@c"+cVarAux+", "
		Next	
	EndIf	
	dbSkip()
EndDo
cQuery+=cQueryAux
cQuery+="@nAKD_VALOR1, @nAKD_VALOR2, @nAKD_VALOR3, @nAKD_VALOR4, @nAKD_VALOR5"+CRLF
cQuery+="   While (@@Fetch_status = 0 ) begin"+CRLF
cQueryAux:= ""
DbSelectArea("AKW")
DbSetOrder(1)
DbSeek( xFilial("AKW")+cCubo)
While xFilial("AKW")+AKW->AKW_COD = xFilial("AKW")+cCubo .and. !Eof()
	aCposAux	:=	Str2Arr( Alltrim(AKW->AKW_CHAVER) , "+")  //quebra em array por delimitador "+"
	If Len(aCposAux) == 1
		cQueryAux +="@c"+Trim(Substring(AKW->AKW_CHAVER,6,Len(AKW->AKW_RELAC)))+", "
	Else
		cQueryAux+="@c"+Alltrim(StrTran(aCposAux[1], "AKD->", ""))+"Aux"+", "
		cVarAux:= ""
		For nZ := 1 TO Len(aCposAux)
//                 = @cAKD_CODPLAAnt||@cAKD_VERSAOAnt		
			cVarAux += "@c"+Alltrim(StrTran(aCposAux[nZ], "AKD->", ""))+If(nZ < Len(aCposAux), "||", "")
		Next
		If Len(cVarAux) > 0
			cQuery +="         select "+"@c"+Alltrim(StrTran(aCposAux[1], "AKD->", ""))+"Aux = "+cVarAux+CRLF
		EndIf
	EndIf
	dbSkip()
EndDo
cQueryAux:= StrTran(cQueryAux,", ","Ant, ")
cQueryAux:= Substring(cQueryAux,1,(Len(cQueryAux)-2))
      /* --------------------------------------------------------------
         Inicia o Atualizacao do AKT p/ cada um dos niveis Conta, CC
         -------------------------------------------------------------- */      
cQuery+="      If @lAtuAKT = '1' begin"+CRLF
         /* --------------------------------------------------------------
            Atualizo a analitica do AKT - apenas uma analitica
            PCOA122B  - proc[3]
            -------------------------------------------------------------- */
cQuery+="         EXEC "+aProc[3]+" @cFilAnt,  @IN_CONFIG, @cDataAnt, @cChaveR, @nValorD1,  @nValorD2,  @nValorD3,    @nValorD4,      @nValorD5,"+CRLF
cQuery+="                          @nValorC1, @nValorC2,  @nValorC3, @nValorC4, @nValorC5, "+cQueryAux/*@cAKD_COAnt, @cAKD_CCAnt, @cAKD_TPSALDAnt*/+CRLF
         /* --------------------------------------------------------------
            Atualizo AKT de níveis sintéticos para cada nivel do cubo 
            PCOA122A - proc[8]
            -------------------------------------------------------------- */
For iProc = 1 to Len(aProcAKT)
	cQuery+="         EXEC "+aProcAKT[iProc]+" @cFilAnt,  @IN_CONFIG, @cDataAnt, @nValorD1, @nValorD2, @nValorD3, @nValorD4, @nValorD5,"+CRLF
	cQuery+="                          @nValorC1, @nValorC2,  @nValorC3,  @nValorC4, @nValorC5, "+cQueryAux /*@cAKD_COAnt, @cAKD_CCAnt, @cAKD_TPSALDAnt*/+CRLF
Next iProc
cQuery+="         select @nValorC1 = 0, @nValorC2 = 0, @nValorC3 = 0, @nValorC4 = 0, @nValorC5 = 0"+CRLF
cQuery+="         select @nValorD1 = 0, @nValorD2 = 0, @nValorD3 = 0, @nValorD4 = 0, @nValorD5 = 0"+CRLF
cQuery+="         select @lAtuAKT = '0'"+CRLF
cQuery+="      End"+CRLF

      /* --------------------------------------------------------------
         Vars para atualizacao do AKT
         -------------------------------------------------------------- */
cQuery+="      If @cAKD_TIPO = '1' begin"+CRLF
cQuery+="         select @nValorC1 = @nAKD_VALOR1"+CRLF
cQuery+="         select @nValorC2 = @nAKD_VALOR2"+CRLF
cQuery+="         select @nValorC3 = @nAKD_VALOR3"+CRLF
cQuery+="         select @nValorC4 = @nAKD_VALOR4"+CRLF
cQuery+="         select @nValorC5 = @nAKD_VALOR5"+CRLF
cQuery+="      end else begin"+CRLF
cQuery+="         select @nValorD1 = @nAKD_VALOR1"+CRLF
cQuery+="         select @nValorD2 = @nAKD_VALOR2"+CRLF
cQuery+="         select @nValorD3 = @nAKD_VALOR3"+CRLF
cQuery+="         select @nValorD4 = @nAKD_VALOR4"+CRLF
cQuery+="         select @nValorD5 = @nAKD_VALOR5"+CRLF
cQuery+="      end"+CRLF

cQuery+="      Select @cDataDiario = SubsTring(@cAKD_DATA,1,6)"+CRLF
cQuery+="      select @cChaveAKT = @cFilial||@cAKD_DATA||"
cQueryAux:= StrTran(cQueryAux,"Ant, ","||")
cQueryAux:= StrTran(cQueryAux,"Ant","")
cQuery+=cQueryAux+CRLF             //"@cAKD_CO||@cAKD_CC||@cAKD_TPSALD"
cQuery+="      select @cChaveR   = "+cQueryAux+CRLF   //@cAKD_CO||@cAKD_CC||@cAKD_TPSALD"+CRLF
cQueryAux:= StrTran(cQueryAux,"||",", ")
cQuery+="      select @cFilAnt  = @cFilial"+CRLF
cQuery+="      select @cDataAnt = @cAKD_DATA"+CRLF
DbSelectArea("AKW")
DbSetOrder(1)
DbSeek( xFilial("AKW")+cCubo)
cQueryAux := ""
While xFilial("AKW")+AKW->AKW_COD = xFilial("AKW")+cCubo .and. !Eof()
	aCposAux	:=	Str2Arr( Alltrim(AKW->AKW_CHAVER) , "+")  //quebra em array por delimitador "+"
	If Len(aCposAux) == 1
		cQueryAux +="      Select @c"+Trim(Substring(AKW->AKW_CHAVER,6,Len(AKW->AKW_CHAVER)))+"Ant = "+"@c"+Trim(Substring(AKW->AKW_CHAVER,6,Len(AKW->AKW_CHAVER)))+CRLF
	Else
		For nZ := 1 TO Len(aCposAux)
			cVarAux := Alltrim(StrTran(aCposAux[nZ], "AKD->", ""))
			cQueryAux +="      Select @c"+cVarAux+"Ant = @c"+cVarAux+CRLF
		Next
		cQueryAux +="      Select @c"+Alltrim(StrTran(aCposAux[1], "AKD->", ""))+"AuxAnt = @c"+Alltrim(StrTran(aCposAux[1], "AKD->", ""))+"Aux"+CRLF
	EndIf
	dbSkip()
EndDo
cQuery+=cQueryAux
cQueryAux:= ""
DbSelectArea("AKW")
DbSetOrder(1)
DbSeek( xFilial("AKW")+cCubo)
While xFilial("AKW")+AKW->AKW_COD = xFilial("AKW")+cCubo .and. !Eof()
	aCposAux	:=	Str2Arr( Alltrim(AKW->AKW_CHAVER) , "+")  //quebra em array por delimitador "+"
	If Len(aCposAux) == 1
		cQueryAux +="@c"+Trim(Substring(AKW->AKW_CHAVER,6,Len(AKW->AKW_RELAC)))+", "
	Else
		For nZ := 1 TO Len(aCposAux)
			cVarAux := Alltrim(StrTran(aCposAux[nZ], "AKD->", ""))
			cQueryAux +="@c"+cVarAux+", "
		Next
	EndIf	
	dbSkip()
EndDo

cQuery+="      Fetch CUR_PCO122 into @cFilial, @cAKD_TIPO, @cAKD_DATA, "+cQueryAux/*@cAKD_CO, @cAKD_CC, @cAKD_TPSALD,*/+"@nAKD_VALOR1, @nAKD_VALOR2, @nAKD_VALOR3, @nAKD_VALOR4,"+CRLF
cQuery+="                             @nAKD_VALOR5"+CRLF
cQueryAux:= SubString(cQueryAux,1, Len(cQueryAux)-2)
cQueryAux:= StrTran(cQueryAux,", ","||")
cQuery+="      select @cChave  = @cFilial||@cAKD_DATA||"+cQueryAux /*@cAKD_CO||@cAKD_CC||@cAKD_TPSALD*/+CRLF
cQuery+="      select @cChave1 = @cFilial||"+cQueryAux /*@cAKD_CO||@cAKD_CC||@cAKD_TPSALD*/+CRLF
If Trim(TcGetDb()) != 'INFORMIX'
	cQuery+="      If @@fetch_status = -1 begin"+CRLF
	cQuery+="         select @cChave  = ' '"+CRLF
	cQuery+="         select @cChave1 = ' '"+CRLF
	cQuery+="      End"+CRLF
EndIf
      /* -----------------------------------------------------------------
         Atualiza @lAtuAKT com '1' para efetuar a gravavao do AKT
         ----------------------------------------------------------------- */
cQuery+="      If @cChave != @cChaveAKT begin"+CRLF
cQuery+="         select @lAtuAKT = '1'"+CRLF
cQuery+="      End"+CRLF

cQuery+="   End"+CRLF
cQueryAux:= ""
DbSelectArea("AKW")
DbSetOrder(1)
DbSeek( xFilial("AKW")+cCubo)
While xFilial("AKW")+AKW->AKW_COD = xFilial("AKW")+cCubo .and. !Eof()
	aCposAux	:=	Str2Arr( Alltrim(AKW->AKW_CHAVER) , "+")  //quebra em array por delimitador "+"
	If Len(aCposAux) == 1
		cQueryAux +="@c"+Trim(Substring(AKW->AKW_CHAVER,6,Len(AKW->AKW_RELAC)))+", "
	Else
		cQueryAux+="@c"+Alltrim(StrTran(aCposAux[1], "AKD->", ""))+"Aux"+", "
	EndIf
	dbSkip()
EndDo
cQueryAux:= StrTran(cQueryAux,", ","Ant, ")
cQueryAux:= Substring(cQueryAux,1,(Len(cQueryAux)-2))
cQuery+="   If @lAtuAKT = '1' begin"+CRLF
         /* --------------------------------------------------------------
            Atualizo a analitica do AKT
            -------------------------------------------------------------- */

cQuery+="         EXEC "+aProc[3]+" @cFilAnt,  @IN_CONFIG, @cDataAnt, @cChaveR, @nValorD1,  @nValorD2,  @nValorD3,    @nValorD4,      @nValorD5,"+CRLF
cQuery+="                          @nValorC1, @nValorC2,  @nValorC3, @nValorC4, @nValorC5, "+cQueryAux/*@cAKD_COAnt, @cAKD_CCAnt, @cAKD_TPSALDAnt*/+CRLF
For iProc = 1 to Len(aProcAKT)
	cQuery+="      EXEC "+aProcAKT[iProc]+" @cFilAnt,  @IN_CONFIG, @cDataAnt, @nValorD1, @nValorD2, @nValorD3, @nValorD4, @nValorD5,"+CRLF
	cQuery+="                       @nValorC1, @nValorC2,  @nValorC3,  @nValorC4, @nValorC5, "+cQueryAux /*@cAKD_COAnt, @cAKD_CCAnt, @cAKD_TPSALDAnt*/+CRLF
Next iProc
cQuery+="   End"+CRLF

cQuery+="   close CUR_PCO122"+CRLF
cQuery+="   deallocate CUR_PCO122"+CRLF
   
cQuery+="   select @OUT_RESULT  = '1'"+CRLF
cQuery+="End"+CRLF

cQuery := MsParse( cQuery, If( Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB()) ) )
cQuery := CtbAjustaP(.F., cQuery, 0)

If Empty( cQuery )
	MsgAlert(MsParseError(),STR0036+cProc)  //'A query da procedure pai nao passou pelo Parse '
	lRet := .F.
Else
	If !TCSPExist( cProc )
		cRet := TcSqlExec(cQuery)
		If cRet <> 0
			If !__lBlind
				MsgAlert(STR0037+cProc)  //"Erro na criacao da procedure Pai: "
				lRet:= .F.
			EndIf
		EndIf
	EndIf
EndIf
RestArea(aSaveArea)

Return( lRet )		


//-----------------------------------------------------------------------------------------------//
//exclusao dos movimentos orcamentarios na revisao da planilha
//-----------------------------------------------------------------------------------------------//

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³P122CDELL   ºAutor  ³Microsiga           º Data ³  24/06/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcão responsavel pela chamada das procedures.               º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PCOA122                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function P122CDELL(cPlanRev, cPlanVers, cItemProc)
Local nProx 	:= 1
Local aProc   	:= {}
Local cArqTrb
Local cArq  	:= ""
Local lRet		:= .T.
Local aResult	:= {}
Local cExec  	:= ""
Local cRet   	:= ""
Local iX      	:= 0

/* ---------------------------------------------------------------------------------------------------------------------
   Versão          - <v> Protheus 9.12 </v>
   Assinatura      - <a> 001 </a>
   Fonte Microsiga - <s> PCOA122.PRX </s>
   Descricao       - <d> exclusao dos movimentos do processo 000252 no item indicado na revisao </d>
   Funcao do Siga  -     
   -----------------------------------------------------------------------------------------------------------------
   Entrada         -  <ri> @IN_FILIALR	- Filial corrente 
       				   		@IN_CONFIG  - Codigo do cubo
         						@IN_FK      - '1' se integridade estiver ligada	</ri>
   -----------------------------------------------------------------------------------------------------------------
   Saida          -  <ro> @OUT_RESULT    -  </ro>
   -----------------------------------------------------------------------------------------------------------------
   Responsavel    -   <r> Alice Yaeko Yamamoto  </r>
   -----------------------------------------------------------------------------------------------------------------
   Data           -  <dt> 08/05/2008 </dt>
   Estrutura de chamadas
   ========= == ========
   Obs.: Não remova os tags acima. Os tags são a base para a geração automática, de documentação, pelo Parse.
   
/*   Ordem de chamada das procedures - Ordem de criacao de procedures 
  **  0.2.CallXFilial  - Xfilial ................................................ 1  aProc[1]
   1.PCOA122_Del - Exclui lancamentos do AKD .................................... 2  aProc[2]
   --------------------------------------------------------------------------------------------------------------------- */
cArqTrb := CriaTrab(,.F.)
cArq    := cArqTRB+StrZero(nProx,2)
AADD( aProc, cArq+"_"+cEmpAnt)
lRet    := CallXFilial( cArq )  // CallXfilial aProc[1]
If lRet
	nProx := nProx + 1
	cArq    := cArqTRB+StrZero(nProx,2)
	cArqAKT := cArq
	AADD( aProc, cArq+"_"+cEmpAnt)           // PCOA122_Del aProc[2]
	lRet   := PCOA122_Del( cArq, aProc )
EndIf
If lRet
	aResult := TCSPExec( xProcedures(cArq), cFilAnt, "000252", cItemProc, cPlanRev, cPlanVers)
	TcRefresh(RetSqlName("AKD"))
	If Empty(aResult) .Or. aResult[1] = "0"
		MsgAlert(tcsqlerror(),STR0038+ProcName())  //"Erro na Revisao - Exclusão de Lancamentos por procedure! "
		lRet := .F.	
	EndIf
EndIf

For iX = 1 to Len(aProc)   // exclusao de aProc
	If TCSPExist(aProc[iX])
		cExec := "Drop procedure "+aProc[iX]
		cRet := TcSqlExec(cExec)
		If cRet <> 0
			MsgAlert(STR0025+aProc[iX] + STR0026) //"Erro na exclusao da Procedure: "###". Excluir manualmente no banco"
		Endif
	EndIf
Next iX

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³PCOA122_Del³ Autor ³                        ³ Data ³21.06.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria procedure de exclusao do AKD                             ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso     ³ SigaPCO                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PCOA122_Del( cArq, aProc  )
Local aSaveArea  := GetArea()
Local cQuery := ""
Local cProc := cArq+"_"+cEmpAnt
Local lRet := .T.

cQuery:="Create Procedure "+cProc+" ("+CRLF
cQuery +="   @IN_FILIAL  char( "+Str(TamSX3("AK2_FILIAL")[1])+" ),"+CRLF
cQuery +="   @IN_PROCES  char( "+Str(TamSX3("AKD_PROCES")[1])+" ),"+CRLF
cQuery +="   @IN_ITEM    char( "+Str(TamSX3("AKD_ITEM")[1])+" ),"+CRLF
cQuery +="   @IN_ORCAME  char( "+Str(TamSX3("AK2_ORCAME")[1])+" ),"+CRLF
cQuery +="   @IN_VERSAO  char( "+Str(TamSX3("AK2_VERSAO")[1])+" ),"+CRLF
cQuery +="   @OUT_RESULT char( 01 ) OutPut"+CRLF
cQuery +=")"+CRLF
cQuery +="as"+CRLF
cQuery +="Declare @cAux char( 03 )"+CRLF
cQuery +="Declare @cFil_AKD char( "+Str(TamSX3("AK2_FILIAL")[1])+" )"+CRLF
cQuery +="Declare @cFil_AK2 char( "+Str(TamSX3("AK2_FILIAL")[1])+" )"+CRLF
cQuery +="Declare @iRecnoAKD integer"+CRLF
cQuery +="Declare @iNroRegs integer"+CRLF
cQuery +="Declare @iTranCount integer"+CRLF //--Var.de ajuste para SQLServer e Sybase.

cQuery +="begin"+CRLF
cQuery +="   select @OUT_RESULT = '0'"+CRLF
cQuery +="   select @iRecnoAKD  = 0"+CRLF
cQuery +="   select @iNroRegs   = 0"+CRLF
cQuery +="   select @cAux = 'AKD'"+CRLF
cQuery +="   exec "+aProc[1]+" @cAux, @IN_FILIAL, @cFil_AKD OutPut"+CRLF
cQuery +="   select @cAux = 'AK2'"+CRLF
cQuery +="   exec "+aProc[1]+"  @cAux, @IN_FILIAL, @cFil_AK2 OutPut"+CRLF
		
cQuery +="   Declare AKD_EXCLUI insensitive cursor for"+CRLF
cQuery +="    SELECT AKD.R_E_C_N_O_"+CRLF
cQuery +="      FROM "+RetSqlName("AKD")+" AKD, "+RetSqlName("AK2")+ " AK2 "+CRLF
cQuery +="     WHERE AKD_FILIAL  = @cFil_AKD"+CRLF
cQuery +="       and AKD_PROCES  = @IN_PROCES"+CRLF
cQuery +="       and AKD_ITEM    = @IN_ITEM"+CRLF
cQuery +="       and AKD_CHAVE   = 'AK2'||AK2_FILIAL||AK2_ORCAME||AK2_VERSAO||AK2_CO||AK2_PERIOD||AK2_ID"+CRLF   //-- PRIMEIRO INDICE DO AK2
cQuery +="       and AKD_TIPO    IN ('1' , '2' )"+CRLF
cQuery +="       and AKD.D_E_L_E_T_  = ' '"+CRLF
cQuery +="       and AK2_FILIAL  = @cFil_AK2"+CRLF
cQuery +="       and AK2_ORCAME  = @IN_ORCAME"+CRLF
cQuery +="       and AK2_VERSAO  = @IN_VERSAO"+CRLF
cQuery +="       and AK2.D_E_L_E_T_  = ' '"+CRLF
cQuery +="   for read only"+CRLF
cQuery +="   Open AKD_EXCLUI"+CRLF
cQuery +="   Fetch AKD_EXCLUI into @iRecnoAKD"+CRLF
	   
cQuery +="   While (@@fetch_status = 0 ) begin"+CRLF
cQuery +="      select @iNroRegs = @iNroRegs + 1"+CRLF
cQuery +="      if @iNroRegs  = 1 begin"+CRLF
cQuery +="         Begin Transaction"+CRLF
cQuery +="         select @iNroRegs  = @iNroRegs"+CRLF
cQuery +="      end"+CRLF
      /* ---------------------------------------------------
		 Exlui AKD
		 --------------------------------------------------- */
cQuery +="      Delete from "+RetSqlName("AKD")+" Where R_E_C_N_O_ = @iRecnoAKD"+CRLF
cQuery +="      if @iNroRegs  >= 15000 begin"+CRLF 
cQuery +="         Commit Transaction"+CRLF
cQuery +="         Select @iNroRegs  = 0"+CRLF
cQuery +="      end"+CRLF
	  
cQuery +="      Fetch AKD_EXCLUI into @iRecnoAKD"+CRLF
cQuery +="   End"+CRLF
cQuery +="   if @iNroRegs  > 0 begin "+CRLF
cQuery +="      Commit Transaction "+CRLF
cQuery +="      select @iTranCount = 0"+CRLF
cQuery +="   end"+CRLF
cQuery +="   close AKD_EXCLUI"+CRLF
cQuery +="   deallocate AKD_EXCLUI"+CRLF
   
cQuery +="   select @OUT_RESULT = '1'"+CRLF
cQuery +="End"+CRLF

cQuery := MsParse( cQuery, If( Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB()) ) )
cQuery := CtbAjustaP(.F., cQuery, 0)

If Empty( cQuery )
	MsgAlert(MsParseError(),STR0039+cProc) //'A query de exclusao de AKD nao passou pelo Parse '
	lRet := .F.
Else
	If !TCSPExist( cProc )
		cRet := TcSqlExec(cQuery)
		If cRet <> 0
			If !__lBlind
				MsgAlert(STR0040+cProc) //"Erro na criacao da proc de Exclusao de linhas do AKD: "
				lRet:= .F.
			EndIf
		EndIf
	EndIf
EndIf
RestArea(aSaveArea)

Return(lRet)

Function P122lAtuCb(lAtualiza)
Default lAtualiza := .T.

_lAtuCubo     := lAtualiza

Return
