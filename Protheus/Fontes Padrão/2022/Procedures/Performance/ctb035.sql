Create procedure CTB035_##
( 
   @IN_FILIALCOR    Char('CT2_FILIAL'),
   @IN_FILIALATE    Char('CT2_FILIAL'),
   @IN_LCUSTO       Char(01),
   @IN_LITEM        Char(01),
   @IN_LCLVL        Char(01),
   @IN_DATADE       Char(08),
   @IN_DATAATE      Char(08),
   @IN_LMOEDAESP    Char(01),
   @IN_MOEDA        Char('CT7_MOEDA'),
   @IN_TPSALDO      Char('CT2_TPSALD'),
   @IN_REPROC       Char(01),
   @IN_INTEGRIDADE  Char(01),
   @IN_MVCTB190D    Char(01),
   @OUT_RESULTADO   Char(01) OutPut
 )
as
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P11 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  CTBA360.PRW </s>
    Descricao       - <d>  Atualizacao de Slds Compostos </d> 
    Funcao do Siga  -      CT360SlCmp - Gravar slds compostos
                               --> ct360grava
                               --> GRVSLDCTU
                    -      Os slds compostos CTU, CTV, CTW, CTX e CTY são gerados a partir 
                           dos slds base ( CT3, CT4, CT7, CTI )
                           CTU - Saldos totais por entidades contábeis
                           CTV - Saldos item/ccusto
                           CTW - Saldos classe de valor/ccusto
                           CTX - Saldos classe de valor/item
                           CTY - Saldos ccusto/item
                           CT3 - Saldo base ccusto
                           CT4 - Saldo base item
                           CT7 - saldo base contas
                           CTI - saldo base classe de valor
    Entrada         - <ri> @IN_FILIALCOR    - Filial Corrente
                           @IN_FILIALATE    - Filial final do processamento
                           @IN_LCUSTO       - Centro de Custo em uso
                           @IN_LITEM        - Item em uso
                           @IN_LCLVL        - Classe de Valor em uso
                           @IN_DATADE       - Range inicial de Data a processar
                           @IN_DATAATE      - Range Final para processar
                           @IN_LMOEDAESP    - Moeda Especifica - '1', todas, exceto orca/o - '0'
                           @IN_MOEDA        - Moeda escolhida  - se '0', todas exceto orcamento
                           @IN_TPSALDO      - Tipos de Saldo a Repropcessar - ('1','2',..)
                           @IN_REPROC       - Se reprocessamento '1'
                           @IN_INTEGRIDADE  - '1' se a integridade estiver ligada, '0' se nao estiver ligada.
                           @IN_MVCTB190D    - '1' exclui fisicamente, '0' marca como deletado </ri>
    Saida           - <ro>  @OUT_RESULTADO   - Indica o termino OK da procedure </ro>
    Responsavel :     <r>  Alice Yamamoto	</r>
    Data        :     03/11/2003
-------------------------------------------------------------------------------------- */
declare @cFilial_CT3 Char('CT3_FILIAL')
declare @cFilial_CT4 Char('CT4_FILIAL')
declare @cFilial_CTI Char('CTI_FILIAL')
declare @cFilial_CTU Char('CTU_FILIAL')
declare @cFilial_CTV Char('CTV_FILIAL')
declare @cFilial_CTW Char('CTW_FILIAL')
declare @cFilial_CTX Char('CTX_FILIAL')
declare @cFilial_CTY Char('CTY_FILIAL')
declare @cAux        Char(03)
declare @cAux2       Char(03)
declare @cAux3       Char(01)
declare @cDataFim    Char(08)
declare @cData       Char(08)
declare @cFILIALXX   Char('CT2_FILIAL')
declare @cMOEDAXX    Char('CT3_MOEDA')
declare @cTPSALDOXX  Char('CT3_TPSALD')
declare @cCUSTOXX    Char('CT3_CUSTO')
declare @cDATAXX     Char(08)
declare @cLPXX       Char('CT3_LP')
declare @cDTLPXX     Char(08)
declare @cIDENTXX    Char('CTU_IDENT')
declare @cITEMXX     Char('CT4_ITEM')
declare @cCLVLXX     Char('CTI_CLVL')
declare @nDEBITO     Float
declare @nCREDIT     Float
declare @nAntDeb     Float
declare @nAntCrd     Float
declare @nAtuDeb     Float
declare @nAtuCrd     Float
declare @cStatus     Char('CTU_STATUS')
declare @cSlComp     Char('CTU_SLCOMP')
declare @iRecno      Integer
declare @iRecnoNew   Integer
declare @cDataDel    Char(08)
declare @iNroRegs    Integer
declare @iTranCount  Integer --Var.de ajuste para SQLServer e Sybase. Será trocada por Commit no CFGX051 após passar pelo Parse
declare @cFilAnt     Char('CT2_FILIAL')
declare @cIDENTAnt   Char( 03)
declare @cMOEDAAnt   Char( 'CT2_MOEDLC' )
declare @cTPSALDOAnt Char( 'CT2_TPSALD' )
declare @cCUSTOAnt   Char( 'CT3_CUSTO' )
declare @cITEMAnt    Char( 'CT4_ITEM' )
declare @cCLVLAnt    Char( 'CTI_CLVL' )
declare @lExec       Char( 01 )

begin
   
   select @OUT_RESULTADO = '0'
   select @iNroRegs = 0
   select @lExec = '1'
   
   select @cAux = 'CTU'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFilial_CTU OutPut
   
   If @IN_LCUSTO = '1' begin
      select @cAux = 'CT3'
      exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFilial_CT3 OutPut
      
      select @cAux  = 'CTU'
      select @cAux2 = 'CTT'
      select @cAux3 = '0'
      /*----------------------------------------------------------------------------
        Ct360Del() - Apaga Saldos compostos das tabelas destino - EXCLUSÃO de dados do   destino ( CTT )
        ----------------------------------------------------------------------------- */
      EXEC CTB036_## @cAux, @cAux2, @cFilial_CTU, @IN_FILIALATE, @IN_DATADE, @IN_DATAATE,
                     @IN_LMOEDAESP,@IN_MOEDA, @IN_TPSALDO, @cAux3, @IN_INTEGRIDADE, @IN_MVCTB190D, @OUT_RESULTADO OutPut
      /*---------------------------------------------------------------
        Atualizacao das entidades do CTU
           - Atualizacao dos slds das Entidades
        --------------------------------------------------------------- */
      select @cFilAnt     = ' '
      select @cIDENTAnt   =  ' '
      select @cMOEDAAnt   =  ' '
      select @cTPSALDOAnt =  ' '
      select @cCUSTOAnt   =  ' '
      
      Declare CUR_CT360SLCMP insensitive cursor for
      Select CT3_FILIAL,       CT3_MOEDA,        CT3_TPSALD, CT3_CUSTO, CT3_DATA, CT3_LP, CT3_DTLP,
             SUM(CT3_DEBITO),  SUM( CT3_CREDIT)
        From CT3###
       Where CT3_FILIAL Between @cFilial_CT3 and @IN_FILIALATE
         and ( ( CT3_MOEDA = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )   
         and CT3_TPSALD = @IN_TPSALDO
         and CT3_DATA   between @IN_DATADE and @IN_DATAATE
         and CT3_CUSTO != ' '
         and (( @IN_REPROC  = '0' and CT3_SLCOMP != 'S') or @IN_REPROC = '1')
         and D_E_L_E_T_  = ' '
      Group by CT3_FILIAL,  CT3_MOEDA, CT3_TPSALD, CT3_CUSTO, CT3_DATA, CT3_LP, CT3_DTLP
      Order by CT3_FILIAL,  CT3_MOEDA, CT3_TPSALD, CT3_CUSTO, CT3_DATA, CT3_LP, CT3_DTLP
      
      for read only
      
      open CUR_CT360SLCMP
      
      fetch CUR_CT360SLCMP into @cFILIALXX, @cMOEDAXX, @cTPSALDOXX, @cCUSTOXX, @cDATAXX,
                                @cLPXX,     @cDTLPXX,  @nDEBITO,    @nCREDIT
      
      select @cIDENTXX   = 'CTT'
      
      while (@@fetch_status = 0) begin
         If @cFilAnt = @cFILIALXX and @cMOEDAAnt = @cMOEDAXX and @cTPSALDOAnt = @cTPSALDOXX and @cCUSTOAnt = @cCUSTOXX begin
            select @nAntDeb = @nAtuDeb
            select @nAntCrd = @nAtuCrd
            select @lExec = '0'
         end else begin
            select @lExec = '1'
            select @nAntDeb = 0
            select @nAntCrd = 0
         end
         
         select @iNroRegs = @iNroRegs + 1
         select @nAtuDeb = 0
         select @nAtuDeb = 0
         select @cStatus = '1'
         select @cSlComp = 'S'
         If @cFILIALXX = ' ' select @cFILIALXX = @cFilial_CTU
         /*----------------------------------------------------------------------------
           Traz o Saldo Anterior do CTU
           ---------------------------------------------------------------------------- */
         If @lExec = '1' begin
            Exec CTB037_## @cFILIALXX, @cMOEDAXX, @cTPSALDOXX, @cCUSTOXX, @cIDENTXX, @cLPXX, @cDATAXX,
                           @nAntDeb OutPut, @nAntCrd OutPut
         End
         
         select @nAtuDeb =  @nAntDeb + @nDEBITO
         select @nAtuCrd =  @nAntCrd + @nCREDIT
         select @iRecno    = 0
         select @iRecnoNew = 0
         /*------------------------------------------------------------------------------
           Atualizaçãode Saldos  no CTU
           ------------------------------------------------------------------------------ */
         Select @iRecno = IsNull(Min(R_E_C_N_O_), 0)
           From CTU###
          Where CTU_FILIAL = @cFILIALXX
            and CTU_IDENT  = 'CTT'
            and CTU_MOEDA  = @cMOEDAXX
            and CTU_TPSALD = @cTPSALDOXX
            and CTU_CODIGO = @cCUSTOXX
            and CTU_DATA   = @cDATAXX
            and CTU_LP     = @cLPXX
            and D_E_L_E_T_ = ' '
         /*-----------------------------------
           ct360grava  - Insert/Update
           CTB038 - INSERT no CTU
           CTB039 - UPDATE no CTU
           ----------------------------------- */
         If @iNroRegs = 1 begin
            Begin transaction
            Select @iNroRegs = @iNroRegs
         end
         If @iRecno = 0 begin
            Select @iRecnoNew = IsNull( Max(R_E_C_N_O_), 0 ) From CTU###
            select @iRecnoNew = @iRecnoNew + 1
            if @iRecnoNew is Null select @iRecnoNew = 1
            
            Exec CTB038_## @cFILIALXX, @cIDENTXX, @cMOEDAXX, @cTPSALDOXX, @cCUSTOXX, @cDATAXX, @cLPXX,
                           @cDTLPXX,   @cStatus,  @cSlComp,  @nDEBITO,    @nCREDIT,  @nAntDeb, @nAntCrd,
                           @nAtuDeb,   @nAtuCrd,  @iRecnoNew
         end else begin
            Exec CTB039_## @cDATAXX, @cLPXX,      @cDTLPXX,   @cStatus,  @cSlComp,  @nDEBITO,    @nCREDIT,
                           @nAntDeb, @nAntCrd,    @nAtuDeb,   @nAtuCrd,  @iRecno
         end
         If @iNroRegs >= 1024 begin
            Commit Transaction
            select @iNroRegs = 0
         End
         select @cFilAnt     = @cFILIALXX
         select @cMOEDAAnt   = @cMOEDAXX
         select @cTPSALDOAnt = @cTPSALDOXX
         select @cCUSTOAnt   = @cCUSTOXX
         
         fetch CUR_CT360SLCMP into @cFILIALXX, @cMOEDAXX, @cTPSALDOXX, @cCUSTOXX, @cDATAXX,
                                   @cLPXX,     @cDTLPXX,  @nDEBITO,    @nCREDIT
      End
      close CUR_CT360SLCMP
      deallocate CUR_CT360SLCMP
      
      If @iNroRegs > 0 begin
         select @iTranCount = 0
         Commit Transaction
      End
   End
   
   If @IN_LITEM = '1' begin
      select @cAux = 'CT4'
      exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFilial_CT4 OutPut
      select @cAux = 'CTV'
      exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFilial_CTV OutPut
      
      select @cAux  = 'CTU'
      select @cAux2 = 'CTD'
      select @cAux3 = '0'
      /*----------------------------------------------------------------------------
        EXCLUSÃO de dados do   destino ( CTU )
        No reprocessa/o tenho só a data mínina, por isso fixado data máxima 31/12/99
        ----------------------------------------------------------------------------- */
      EXEC CTB036_## @cAux, @cAux2, @cFilial_CTU, @IN_FILIALATE, @IN_DATADE, @IN_DATAATE,
                     @IN_LMOEDAESP,@IN_MOEDA, @IN_TPSALDO, @cAux3, @IN_INTEGRIDADE, @IN_MVCTB190D, @OUT_RESULTADO OutPut
      
      If @IN_LCUSTO = '1' begin
         /*----------------------------------------------------------------------------
           Se tiver Item e Centro de custo 
           EXCLUSÃO de dados do   destino ( CTV )
           No reprocessa/o tenho só a data mínina, por isso fixado data máxima 31/12/99
           ----------------------------------------------------------------------------- */
         select @cAux  = 'CTV'
         select @cAux2 = ' '
         select @cAux3 = '0'
         EXEC CTB036_## @cAux, @cAux2, @cFilial_CTV, @IN_FILIALATE, @IN_DATADE, @IN_DATAATE,
                        @IN_LMOEDAESP,@IN_MOEDA, @IN_TPSALDO, @cAux3, @IN_INTEGRIDADE, @IN_MVCTB190D, @OUT_RESULTADO OutPut
      End
      
      select @cFilAnt     = ' '
      select @cIDENTAnt   =  ' '
      select @cMOEDAAnt   =  ' '
      select @cTPSALDOAnt =  ' '
      select @cCUSTOAnt   =  ' '
      select @cITEMAnt    =  ' '
      
      select @iNroRegs = 0
      Declare CUR_CT360ITEM insensitive cursor for
      Select CT4_FILIAL, 'CTU' ,  CT4_MOEDA, CT4_TPSALD, ' ',  CT4_ITEM, CT4_DATA,
             CT4_LP,    CT4_DTLP, SUM(CT4_DEBITO), SUM(CT4_CREDIT)
        From CT4###
       Where CT4_FILIAL between @cFilial_CT4 and @IN_FILIALATE
         and CT4_TPSALD = @IN_TPSALDO
         and ( ( CT4_MOEDA = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )   
         and CT4_DATA between @IN_DATADE and @IN_DATAATE
         and CT4_ITEM != ' '
         and D_E_L_E_T_ = ' '
      Group By  CT4_FILIAL,  CT4_MOEDA, CT4_TPSALD, CT4_ITEM, CT4_DATA, CT4_LP, CT4_DTLP
      Union
      Select CT4_FILIAL, 'CTV', CT4_MOEDA, CT4_TPSALD, CT4_CUSTO, CT4_ITEM, CT4_DATA,
             CT4_LP,     CT4_DTLP, SUM( CT4_DEBITO), SUM( CT4_CREDIT)
        From CT4###
       Where CT4_FILIAL between @cFilial_CT4 and @IN_FILIALATE
         and CT4_TPSALD = @IN_TPSALDO
         and ( ( CT4_MOEDA = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )   
         and CT4_DATA   between @IN_DATADE and @IN_DATAATE
         and CT4_CUSTO  != ' '
         and D_E_L_E_T_  = ' '
      Group By CT4_FILIAL, CT4_MOEDA, CT4_TPSALD, CT4_ITEM, CT4_CUSTO, CT4_DATA, CT4_LP, CT4_DTLP
      Order By 1,2,3,4,5,6,7,8,9
      for read only
      
      open CUR_CT360ITEM
      
      fetch CUR_CT360ITEM into @cFILIALXX, @cIDENTXX, @cMOEDAXX, @cTPSALDOXX, @cCUSTOXX, @cITEMXX, @cDATAXX,
                               @cLPXX,     @cDTLPXX,  @nDEBITO,  @nCREDIT
      
      while (@@fetch_status = 0) begin
         If @cFilAnt = @cFILIALXX and @cIDENTAnt = @cIDENTXX and @cMOEDAAnt = @cMOEDAXX and @cTPSALDOAnt = @cTPSALDOXX and
            @cCUSTOAnt = @cCUSTOXX and @cITEMAnt = @cITEMXX begin
            select @nAntDeb = @nAtuDeb
            select @nAntCrd = @nAtuCrd
            select @lExec = '0'
         end else begin
            select @lExec = '1'
            select @nAntDeb = 0
            select @nAntCrd = 0
         end
         select @iNroRegs = @iNroRegs + 1
         select @nAtuDeb = 0
         select @nAtuDeb = 0
         select @cStatus = '1'
         select @cSlComp = 'S'
         
         If (@cFILIALXX = ' ' and @cIDENTXX = 'CTU') select @cFILIALXX = @cFilial_CTU
         If (@cFILIALXX = ' ' and @cIDENTXX = 'CTV') select @cFILIALXX = @cFilial_CTV
         
         If @iNroRegs = 1 begin
            Begin Transaction
            Select @iNroRegs = @iNroRegs
         End      
         If @cIDENTXX = 'CTU' begin
            /*----------------------------------------------------------------------------
              Traz o Saldo Anterior do CTU
              SLDANTCTU  - Recuperar slds a debito e credito anteriores a data inicial
              ---------------------------------------------------------------------------- */
            If @lExec = '1' begin
               select @cAux = 'CTD'
               Exec CTB037_## @cFILIALXX, @cMOEDAXX, @cTPSALDOXX, @cITEMXX, @cAux, @cLPXX, @cDATAXX,
                              @nAntDeb OutPut, @nAntCrd OutPut
            End
            
            select @nAtuDeb =  @nAntDeb + @nDEBITO
            select @nAtuCrd =  @nAntCrd + @nCREDIT
            select @iRecno    = 0
            select @iRecnoNew = 0
            /*------------------------------------------------------------------------------
              Atualizaçãode Saldos  no CTU
              ------------------------------------------------------------------------------ */
            Select @iRecno = IsNull(Min(R_E_C_N_O_), 0)
              From CTU###
             Where CTU_FILIAL = @cFILIALXX
               and CTU_IDENT  = 'CTD'
               and CTU_MOEDA  = @cMOEDAXX
               and CTU_TPSALD = @cTPSALDOXX
               and CTU_CODIGO = @cITEMXX
               and CTU_DATA   = @cDATAXX
               and CTU_LP     = @cLPXX
               and D_E_L_E_T_ = ' '
            
            /*-----------------------------------
              ct360grava  - Insert/Update
              CTB038 - INSERT no CTU
              CTB039 - UPDATE no CTU
              ----------------------------------- */
            If @iRecno = 0 begin
               Select @iRecnoNew = IsNull( Max(R_E_C_N_O_), 0 ) From CTU###
               select @iRecnoNew = @iRecnoNew + 1
               if @iRecnoNew is Null select @iRecnoNew = 1
               select @cAux = 'CTD'
               
               Exec CTB038_## @cFILIALXX, @cAux,     @cMOEDAXX, @cTPSALDOXX, @cITEMXX, @cDATAXX, @cLPXX,
                              @cDTLPXX,   @cStatus,  @cSlComp,  @nDEBITO,    @nCREDIT,  @nAntDeb, @nAntCrd,
                              @nAtuDeb,   @nAtuCrd,  @iRecnoNew
            end else begin
               Exec CTB039_## @cDATAXX, @cLPXX,      @cDTLPXX,   @cStatus,  @cSlComp,  @nDEBITO,    @nCREDIT,
                              @nAntDeb, @nAntCrd,    @nAtuDeb,   @nAtuCrd,  @iRecno
            end
         End
         /*------------------------------------------------------------------------------
           Atualizaçãode Saldos  no CTV
           ------------------------------------------------------------------------------ */
         If @cIDENTXX = 'CTV' begin
            /*----------------------------------------------------------------------------
              Traz o Saldo Anterior do CTV
              ---------------------------------------------------------------------------- */
            If @lExec = '1' begin
               Exec CTB040_## @cFILIALXX, @cMOEDAXX, @cTPSALDOXX, @cCUSTOXX, @cITEMXX, @cLPXX, @cDATAXX,
                              @nAntDeb OutPut, @nAntCrd OutPut
            End
            
            select @nAtuDeb =  @nAntDeb + @nDEBITO
            select @nAtuCrd =  @nAntCrd + @nCREDIT
            select @iRecno    = 0
            select @iRecnoNew = 0
            
            Select @iRecno = IsNull(Min(R_E_C_N_O_), 0)
              From CTV###
             Where CTV_FILIAL = @cFILIALXX
               and CTV_MOEDA  = @cMOEDAXX
               and CTV_TPSALD = @cTPSALDOXX
               and CTV_ITEM   = @cITEMXX
               and CTV_CUSTO  = @cCUSTOXX
               and CTV_DATA   = @cDATAXX
               and CTV_LP     = @cLPXX
               and D_E_L_E_T_ = ' '
            
            /*-----------------------------------
              ct360grava  - Insert/Update
              CTB041 - INSERT no CTV
              CTB042 - UPDATE no CTV
              ----------------------------------- */
            If @iRecno = 0 begin
               Select @iRecnoNew = IsNull( Max(R_E_C_N_O_), 0 ) From CTV###
               select @iRecnoNew = @iRecnoNew + 1
               if @iRecnoNew is Null select @iRecnoNew = 1
               
               Exec CTB041_## @cFILIALXX, @cMOEDAXX, @cTPSALDOXX, @cCUSTOXX, @cITEMXX,  @cDATAXX, @cLPXX,
                              @cDTLPXX,   @cStatus,  @cSlComp,  @nDEBITO,    @nCREDIT,  @nAntDeb, @nAntCrd,
                              @nAtuDeb,   @nAtuCrd,  @iRecnoNew
            end else begin
               Exec CTB042_## @cDATAXX, @cLPXX,      @cDTLPXX,   @cStatus,  @cSlComp,  @nDEBITO,    @nCREDIT,
                              @nAntDeb, @nAntCrd,    @nAtuDeb,   @nAtuCrd,  @iRecno
            end
         End
         If @iNroRegs >= 1024 begin
            Commit Transaction
            select @iNroRegs = 0
         End
         Select @cFilAnt     = @cFILIALXX
         Select @cMOEDAAnt   = @cMOEDAXX
         Select @cTPSALDOAnt = @cTPSALDOXX
         Select @cCUSTOAnt   = @cCUSTOXX
         Select @cITEMAnt    = @cITEMXX
         Select @cIDENTAnt   = @cIDENTXX
         
         fetch CUR_CT360ITEM into @cFILIALXX, @cIDENTXX, @cMOEDAXX, @cTPSALDOXX, @cCUSTOXX, @cITEMXX, @cDATAXX,
                                  @cLPXX,     @cDTLPXX,  @nDEBITO,  @nCREDIT
      end
      close CUR_CT360ITEM
      deallocate CUR_CT360ITEM
      
      If @iNroRegs > 0 begin
         select @iTranCount = 0
         Commit Transaction
      End
   End
   
   If @IN_LCLVL = '1' begin
      select @cAux = 'CTI'
      exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFilial_CTI OutPut
      select @cAux = 'CTX'
      exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFilial_CTX OutPut
      select @cAux = 'CTY'
      exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFilial_CTY OutPut
      select @cAux = 'CTW'
      exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFilial_CTW OutPut
      
      select @cAux  = 'CTU'
      select @cAux2 = 'CTH'
      select @cAux3 = '0'
      select @iNroRegs = 0
      /*----------------------------------------------------------------------------
        EXCLUSÃO de dados do   destino ( CTU )
        No reprocessa/o tenho só a data mínina, por isso fixado data máxima 31/12/99
        ----------------------------------------------------------------------------- */
      EXEC CTB036_## @cAux, @cAux2, @cFilial_CTU, @IN_FILIALATE, @IN_DATADE, @IN_DATAATE,
                     @IN_LMOEDAESP,@IN_MOEDA, @IN_TPSALDO, @cAux3, @IN_INTEGRIDADE, @IN_MVCTB190D, @OUT_RESULTADO OutPut
      /*----------------------------------------------------------------------------
        EXCLUSÃO de dados do   destino ( CTW )
        Se existir Clvl e Custo zero CTW
        ----------------------------------------------------------------------------- */
      If @IN_LCUSTO = '1' begin
         select @cAux  = 'CTW'
         select @cAux2 = ' '
         select @cAux3 = '0'
         EXEC CTB036_## @cAux, @cAux2, @cFilial_CTW, @IN_FILIALATE, @IN_DATADE, @IN_DATAATE,
                        @IN_LMOEDAESP,@IN_MOEDA, @IN_TPSALDO, @cAux3, @IN_INTEGRIDADE, @IN_MVCTB190D, @OUT_RESULTADO OutPut
      End
      /*----------------------------------------------------------------------------
        EXCLUSÃO de dados do   destino ( CTX )
        Se existir Clvl e item zero CTX
        ----------------------------------------------------------------------------- */
      If @IN_LITEM = '1' begin
         select @cAux  = 'CTX'
         select @cAux2 = ' '
         select @cAux3 = '0'
         
         EXEC CTB036_## @cAux, @cAux2, @cFilial_CTX, @IN_FILIALATE, @IN_DATADE, @IN_DATAATE,
                        @IN_LMOEDAESP,@IN_MOEDA, @IN_TPSALDO, @cAux3, @IN_INTEGRIDADE, @IN_MVCTB190D, @OUT_RESULTADO OutPut
      End
      /*----------------------------------------------------------------------------
        EXCLUSÃO de dados do   destino ( CTY )
        Se existir Clvl, Custo e Item zero CTY
        ----------------------------------------------------------------------------- */
      If @IN_LCUSTO = '1' AND @IN_LITEM = '1' begin
         select @cAux  = 'CTY'
         select @cAux2 = ' '
         select @cAux3 = '0'
         
         EXEC CTB036_## @cAux, @cAux2, @cFilial_CTY, @IN_FILIALATE, @IN_DATADE, @IN_DATAATE,
                        @IN_LMOEDAESP,@IN_MOEDA, @IN_TPSALDO, @cAux3, @IN_INTEGRIDADE, @IN_MVCTB190D, @OUT_RESULTADO OutPut
      End
      /*---------------------------------------------------------------
        Atualizacao das entidades do CTU
           - Atualizacao dos slds das Entidades
        --------------------------------------------------------------- */
      select @cFilAnt     = ' '
      select @cIDENTAnt   =  ' '
      select @cMOEDAAnt   =  ' '
      select @cTPSALDOAnt =  ' '
      select @cCUSTOAnt   =  ' '
      select @cITEMAnt    =  ' '
      select @cCLVLAnt    =  ' '
      
      Declare CUR_CT360CLVL insensitive cursor for
      Select CTI_FILIAL, 'CTU',  CTI_MOEDA, CTI_TPSALD, ' ', ' ',
             CTI_CLVL, CTI_DATA, CTI_LP, CTI_DTLP, SUM(CTI_DEBITO), SUM(CTI_CREDIT)
        From CTI###
       Where CTI_FILIAL between @cFilial_CTI and @IN_FILIALATE
         and CTI_TPSALD= @IN_TPSALDO
         and ( ( CTI_MOEDA = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )   
         and CTI_DATA between @IN_DATADE and @IN_DATAATE
         and CTI_CLVL != ' '
         and D_E_L_E_T_ = ' '
      Group by CTI_FILIAL, CTI_MOEDA,CTI_TPSALD,CTI_CLVL,CTI_DATA,CTI_LP,CTI_DTLP
      Union
      Select CTI_FILIAL, 'CTW',  CTI_MOEDA, CTI_TPSALD, CTI_CUSTO, ' ',
             CTI_CLVL, CTI_DATA, CTI_LP, CTI_DTLP, SUM(CTI_DEBITO), SUM(CTI_CREDIT)
        From CTI###
       Where CTI_FILIAL between @cFilial_CTI and @IN_FILIALATE
         and CTI_TPSALD= @IN_TPSALDO
         and ( ( CTI_MOEDA = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )   
         and CTI_CUSTO != ' '
         and CTI_DATA between @IN_DATADE and @IN_DATAATE
         and D_E_L_E_T_ = ' '
      Group by CTI_FILIAL, CTI_MOEDA,CTI_TPSALD,CTI_CLVL,CTI_CUSTO,CTI_DATA, CTI_LP, CTI_DTLP
      Union
      Select CTI_FILIAL, 'CTX', CTI_MOEDA, CTI_TPSALD, ' ', CTI_ITEM,
             CTI_CLVL, CTI_DATA, CTI_LP, CTI_DTLP, SUM(CTI_DEBITO), SUM(CTI_CREDIT)
        From CTI###
       Where CTI_FILIAL between @cFilial_CTI and @IN_FILIALATE
         and CTI_TPSALD= @IN_TPSALDO
         and ( ( CTI_MOEDA = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )   
         and CTI_ITEM != ' '
         and CTI_DATA between @IN_DATADE and @IN_DATAATE
         and D_E_L_E_T_ = ' '
      Group by CTI_FILIAL, CTI_MOEDA,CTI_TPSALD,CTI_CLVL,CTI_ITEM,CTI_DATA,CTI_LP,CTI_DTLP
      Union
      Select CTI_FILIAL, 'CTY', CTI_MOEDA, CTI_TPSALD, CTI_CUSTO, CTI_ITEM,
             CTI_CLVL, CTI_DATA, CTI_LP, CTI_DTLP, SUM(CTI_DEBITO), SUM(CTI_CREDIT)
        From CTI###
       Where CTI_FILIAL between @cFilial_CTI and @IN_FILIALATE
         and CTI_TPSALD= @IN_TPSALDO
         and ( ( CTI_MOEDA = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
         and CTI_CUSTO != ' '
         and CTI_ITEM != ' '
         and CTI_DATA between @IN_DATADE and @IN_DATAATE
         and D_E_L_E_T_ = ' '
      Group by CTI_FILIAL, CTI_MOEDA,CTI_TPSALD,CTI_CLVL,CTI_ITEM,CTI_CUSTO,CTI_DATA,CTI_LP,CTI_DTLP
      Order by  1,2,3,4,5,6,7,8,9,10
      
      for read only
      
      open CUR_CT360CLVL
      
      fetch CUR_CT360CLVL into @cFILIALXX, @cIDENTXX, @cMOEDAXX, @cTPSALDOXX, @cCUSTOXX, @cITEMXX, @cCLVLXX, @cDATAXX,
                               @cLPXX,     @cDTLPXX, @nDEBITO,   @nCREDIT
      
      while (@@fetch_status = 0) begin
         If @cFilAnt = @cFILIALXX and @cIDENTAnt = @cIDENTXX and @cMOEDAAnt = @cMOEDAXX and @cTPSALDOAnt = @cTPSALDOXX and
            @cCUSTOAnt = @cCUSTOXX and @cITEMAnt = @cITEMXX and @cCLVLAnt = @cCLVLXX begin
            select @nAntDeb = @nAtuDeb
            select @nAntCrd = @nAtuCrd
            select @lExec = '0'
         end else begin
            select @lExec = '1'
            select @nAntDeb = 0
            select @nAntCrd = 0
         end
         select @iNroRegs = @iNroRegs + 1
         select @nAtuDeb = 0
         select @nAtuDeb = 0
         select @cStatus = '1'
         select @cSlComp = 'S'
         If (@cFILIALXX = ' ' and @cIDENTXX = 'CTU') select @cFILIALXX = @cFilial_CTU
         If (@cFILIALXX = ' ' and @cIDENTXX = 'CTW') select @cFILIALXX = @cFilial_CTW
         If (@cFILIALXX = ' ' and @cIDENTXX = 'CTX') select @cFILIALXX = @cFilial_CTX
         If (@cFILIALXX = ' ' and @cIDENTXX = 'CTY') select @cFILIALXX = @cFilial_CTY
         
         If @iNroRegs = 1 Begin
            Begin Transaction
            Select @iNroRegs = @iNroRegs
         End
         If @cIDENTXX = 'CTU' begin
            /*----------------------------------------------------------------------------
              Traz o Saldo Anterior do CTU
              SLDANTCTU  - Recuperar slds a debito e credito anteriores a data inicial
              ---------------------------------------------------------------------------- */
            If @lExec = '1' begin
               select @cAux = 'CTH'
               Exec CTB037_## @cFILIALXX, @cMOEDAXX, @cTPSALDOXX, @cCLVLXX, @cAux, @cLPXX, @cDATAXX,
                              @nAntDeb OutPut, @nAntCrd OutPut
            End
            
            select @nAtuDeb =  @nAntDeb + @nDEBITO
            select @nAtuCrd =  @nAntCrd + @nCREDIT
            select @iRecno    = 0
            select @iRecnoNew = 0
            /*------------------------------------------------------------------------------
              Atualizaçãode Saldos  no CTU
              ------------------------------------------------------------------------------ */
            Select @iRecno = IsNull(Min(R_E_C_N_O_), 0)
              From CTU###
             Where CTU_FILIAL = @cFILIALXX
               and CTU_IDENT  = 'CTH'
               and CTU_MOEDA  = @cMOEDAXX
               and CTU_TPSALD = @cTPSALDOXX
               and CTU_CODIGO = @cCLVLXX
               and CTU_DATA   = @cDATAXX
               and CTU_LP     = @cLPXX
               and D_E_L_E_T_ = ' '
            
            /*-----------------------------------
               ct360grava  - Insert/Update
               CTB038 - INSERT no CTU
               CTB039 - UPDATE no CTU
              ----------------------------------- */
            If @iRecno = 0 begin
               Select @iRecnoNew = IsNull( Max(R_E_C_N_O_), 0 ) From CTU###
               select @iRecnoNew = @iRecnoNew + 1
               if @iRecnoNew is Null select @iRecnoNew = 1
               
               select @cAux = 'CTH'
               
               Exec CTB038_## @cFILIALXX, @cAux,     @cMOEDAXX, @cTPSALDOXX, @cCLVLXX, @cDATAXX, @cLPXX,
                              @cDTLPXX,   @cStatus,  @cSlComp,  @nDEBITO,    @nCREDIT,  @nAntDeb, @nAntCrd,
                              @nAtuDeb,   @nAtuCrd,  @iRecnoNew
            end else begin
               Exec CTB039_## @cDATAXX, @cLPXX,      @cDTLPXX,   @cStatus,  @cSlComp,  @nDEBITO,    @nCREDIT,
                              @nAntDeb, @nAntCrd,    @nAtuDeb,   @nAtuCrd,  @iRecno
            end
         End
         /*------------------------------------------------------------------------------
           Atualizaçãode Saldos  no CTW
           ------------------------------------------------------------------------------ */
         If @cIDENTXX = 'CTW' begin
            /*----------------------------------------------------------------------------
              Traz o Saldo Anterior do CTW
              ---------------------------------------------------------------------------- */
            If @lExec = '1' begin
               Exec CTB043_## @cFILIALXX, @cMOEDAXX, @cTPSALDOXX, @cCUSTOXX, @cCLVLXX, @cLPXX, @cDATAXX,
                              @nAntDeb OutPut, @nAntCrd OutPut
            End
            
            select @nAtuDeb =  @nAntDeb + @nDEBITO
            select @nAtuCrd =  @nAntCrd + @nCREDIT
            select @iRecno    = 0
            select @iRecnoNew = 0
            
            Select @iRecno = IsNull(Min(R_E_C_N_O_), 0)
              From CTW###
             Where CTW_FILIAL = @cFILIALXX
               and CTW_MOEDA  = @cMOEDAXX
               and CTW_TPSALD = @cTPSALDOXX
               and CTW_CLVL   = @cCLVLXX
               and CTW_CUSTO  = @cCUSTOXX
               and CTW_DATA   = @cDATAXX
               and CTW_LP     = @cLPXX
               and D_E_L_E_T_ = ' '
            /*-----------------------------------
              ct360grava  - Insert/Update
              CTB044 - INSERT no CTW
              CTB045 - UPDATE no CTW
              ----------------------------------- */
            If @iRecno = 0 begin
               Select @iRecnoNew = IsNull( Max(R_E_C_N_O_), 0 ) From CTW###
               select @iRecnoNew = @iRecnoNew + 1
               if @iRecnoNew is Null select @iRecnoNew = 1
               
               Exec CTB044_## @cFILIALXX, @cMOEDAXX, @cTPSALDOXX, @cCUSTOXX, @cCLVLXX,  @cDATAXX, @cLPXX,
                              @cDTLPXX,   @cStatus,  @cSlComp,    @nDEBITO,  @nCREDIT,  @nAntDeb, @nAntCrd,
                              @nAtuDeb,   @nAtuCrd,  @iRecnoNew
            end else begin
               
               Exec CTB045_## @cDATAXX, @cLPXX,      @cDTLPXX,   @cStatus,  @cSlComp,  @nDEBITO,    @nCREDIT,
                              @nAntDeb, @nAntCrd,    @nAtuDeb,   @nAtuCrd,  @iRecno
            end
         End
         /*------------------------------------------------------------------------------
           Atualizaçãode Saldos  no CTX
           ------------------------------------------------------------------------------ */
         If @cIDENTXX = 'CTX' begin
            /*----------------------------------------------------------------------------
              Traz o Saldo Anterior do CTX - Clvl/Item
              ---------------------------------------------------------------------------- */
            If @lExec = '1' begin
               Exec CTB046_## @cFILIALXX, @cMOEDAXX, @cTPSALDOXX, @cITEMXX, @cCLVLXX, @cLPXX, @cDATAXX,
                              @nAntDeb OutPut, @nAntCrd OutPut
            End
            
            select @nAtuDeb =  @nAntDeb + @nDEBITO
            select @nAtuCrd =  @nAntCrd + @nCREDIT
            select @iRecno    = 0
            select @iRecnoNew = 0
            
            Select @iRecno = IsNull(Min(R_E_C_N_O_), 0)
              From CTX###
             Where CTX_FILIAL = @cFILIALXX
               and CTX_MOEDA  = @cMOEDAXX
               and CTX_TPSALD = @cTPSALDOXX
               and CTX_CLVL   = @cCLVLXX
               and CTX_ITEM   = @cITEMXX
               and CTX_DATA   = @cDATAXX
               and CTX_LP     = @cLPXX
               and D_E_L_E_T_ = ' '
            
            /*-----------------------------------
              ct360grava  - Insert/Update
              CTB047 - INSERT no CTX
              CTB048 - UPDATE no CTX
              ----------------------------------- */
            If @iRecno = 0 begin
               Select @iRecnoNew = IsNull( Max(R_E_C_N_O_), 0 ) From CTX###
               select @iRecnoNew = @iRecnoNew + 1
               if @iRecnoNew is Null select @iRecnoNew = 1
               
               Exec CTB047_## @cFILIALXX, @cMOEDAXX, @cTPSALDOXX, @cITEMXX, @cCLVLXX,  @cDATAXX, @cLPXX,
                              @cDTLPXX,   @cStatus,  @cSlComp,    @nDEBITO,  @nCREDIT,  @nAntDeb, @nAntCrd,
                              @nAtuDeb,   @nAtuCrd,  @iRecnoNew
            end else begin
               
               Exec CTB048_## @cDATAXX, @cLPXX,      @cDTLPXX,   @cStatus,  @cSlComp,  @nDEBITO,    @nCREDIT,
                              @nAntDeb, @nAntCrd,    @nAtuDeb,   @nAtuCrd,  @iRecno
            end
         End
         /*------------------------------------------------------------------------------
           Atualizaçãode Saldos  no CTY
           ------------------------------------------------------------------------------ */
         If @cIDENTXX = 'CTY' begin
            /*----------------------------------------------------------------------------
              Traz o Saldo Anterior do CTY - Custo/Item/ClVl
              ---------------------------------------------------------------------------- */
            If @lExec = '1' begin
               Exec CTB049_## @cFILIALXX, @cMOEDAXX, @cTPSALDOXX, @cCUSTOXX, @cITEMXX, @cCLVLXX, @cLPXX, @cDATAXX,
                              @nAntDeb OutPut, @nAntCrd OutPut
            End
            
            select @nAtuDeb =  @nAntDeb + @nDEBITO
            select @nAtuCrd =  @nAntCrd + @nCREDIT
            select @iRecno    = 0
            select @iRecnoNew = 0
            
            Select @iRecno = IsNull(Min(R_E_C_N_O_), 0)
              From CTY###
             Where CTY_FILIAL = @cFILIALXX
               and CTY_MOEDA  = @cMOEDAXX
               and CTY_TPSALD = @cTPSALDOXX
               and CTY_CLVL   = @cCLVLXX
               and CTY_ITEM   = @cITEMXX
               and CTY_CUSTO  = @cCUSTOXX
               and CTY_DATA   = @cDATAXX
               and CTY_LP     = @cLPXX
               and D_E_L_E_T_ = ' '
            
            /*-----------------------------------
              ct360grava  - Insert/Update
              CTB050 - INSERT no CTY
              CTB051 - UPDATE no CTY
              ----------------------------------- */
            If @iRecno = 0 begin
               Select @iRecnoNew = IsNull( Max(R_E_C_N_O_), 0 ) From CTY###
               select @iRecnoNew = @iRecnoNew + 1
               if @iRecnoNew is Null select @iRecnoNew = 1
               
               Exec CTB050_## @cFILIALXX, @cMOEDAXX, @cTPSALDOXX, @cCUSTOXX, @cITEMXX, @cCLVLXX,  @cDATAXX, @cLPXX,
                              @cDTLPXX,   @cStatus,  @cSlComp,    @nDEBITO,  @nCREDIT,  @nAntDeb, @nAntCrd,
                              @nAtuDeb,   @nAtuCrd,  @iRecnoNew
            end else begin
               Exec CTB051_## @cDATAXX, @cLPXX,      @cDTLPXX,   @cStatus,  @cSlComp,  @nDEBITO,    @nCREDIT,
                              @nAntDeb, @nAntCrd,    @nAtuDeb,   @nAtuCrd,  @iRecno
            end
         End
         If @iNroRegs >= 1024 begin
            Commit Transaction
            select @iNroRegs = 0
         End
         select @cFilAnt     = @cFILIALXX
         select @cIDENTAnt   = @cIDENTXX
         select @cMOEDAAnt   = @cMOEDAXX
         select @cTPSALDOAnt = @cTPSALDOXX
         select @cCUSTOAnt   = @cCUSTOXX
         select @cITEMAnt    = @cITEMXX
         select @cCLVLAnt    = @cCLVLXX
         
         fetch CUR_CT360CLVL into @cFILIALXX, @cIDENTXX, @cMOEDAXX, @cTPSALDOXX, @cCUSTOXX, @cITEMXX, @cCLVLXX, @cDATAXX,
                                  @cLPXX,     @cDTLPXX, @nDEBITO,   @nCREDIT
      end
      close CUR_CT360CLVL
      deallocate CUR_CT360CLVL
      
      If @iNroRegs > 0 begin
         select @iTranCount = 0
         Commit Transaction
      End
   End
   
   /*---------------------------------------------------------------
     CTB052  - Ct360Flag - Atualiza flag de slds compostos
     --------------------------------------------------------------- */
   If @IN_LCUSTO = '1' begin
      select @cAux2 = 'CT3'
      exec CTB052_## @cFilial_CT3, @IN_FILIALATE, @cAux2, @IN_DATADE, @IN_DATAATE, @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO
   End
   If @IN_LITEM = '1' begin
      select @cAux2 = 'CT4'
      exec CTB052_## @cFilial_CT4, @IN_FILIALATE, @cAux2, @IN_DATADE, @IN_DATAATE, @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO
   End
   If @IN_LCLVL = '1' begin
      select @cAux2 = 'CTI'
      exec CTB052_## @cFilial_CTI, @IN_FILIALATE, @cAux2, @IN_DATADE, @IN_DATAATE, @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO
   End
   /*---------------------------------------------------------------
     Se a execucao foi OK retorna '1'
     --------------------------------------------------------------- */
   select @OUT_RESULTADO = '1'
end

