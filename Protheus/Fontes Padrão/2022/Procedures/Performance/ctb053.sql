
Create procedure CTB053_##

 ( 
  @IN_FILIALCOR    Char(02),
  @IN_CONTADOR     Integer,
  @IN_ARRAY        Char(250),
  @IN_FILIALDE     Char(02),
  @IN_FILIALATE    Char(02),
  @OUT_RESULTADO   Char(1) OutPut

 )

as

/* ------------------------------------------------------------------------------
   Versão          - <v> Protheus 9.12 </v>
   Programa        - <s> Ct400Saldo.prw </s>
   Assinatura      - <a> 001 </a>
   Descricao       - <d> Encerramento do Exercicio Contabil  </d>   
   Entrada         - <ri> @IN_FILIALCOR   -   Codigo da Filial Corrente
                          @IN_CONTADOR    -   Numero de registros na variável @IN_ARRAY
                          @IN_ARRAY       -   Registro -> #01+2002+03 
                                              Separador => #                    
                                              Calendario => 01 
                                              Exercicio => 2002 
                                              Moeda => 03
                          @IN_FILIADE     -   Codigo da Filial Inicial 
                          @IN_FILIALATE   -   Codigo da Filial Final  

                           
   Responsavel :     <r> Ricardo Castillo Pereira </r>
   Data        :  01.04.04
----------------------------------------------------------------------------- */

declare @iMinRecno    integer
declare @iMaxRecno    integer
declare @iContador    integer
declare @x            integer
declare @dDataIni     Char(08) 
declare @dDataFin     Char(08)
declare @cAux         Char(03)
declare @cFil_CTG     Char(02)
declare @cCalend      Char(03)
declare @cExerc       Char(04)
declare @cMoeda       Char(02)
declare @pos          integer
declare @pos1         integer
declare @pos2         integer
declare @pos3         integer
declare @pos4         integer
declare @Prox         integer

begin
                                 
   select @OUT_RESULTADO = '0'
   select @pos = 1
   select @pos1 = 0
   select @pos2 = 0
   select @pos3 = 0
   select @pos4 = 0
   select @Prox = 0
   select @x = 1

   select @cAux = 'CTG'
   EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_CTG OutPut
 
   while  @x <= @IN_CONTADOR begin 

         select @pos = @pos + @Prox
         select @pos1 = Charindex('#',@IN_ARRAY,@pos)
         select @pos2 = Charindex('+',@IN_ARRAY,@pos)
         select @cCalend = Substring(@IN_ARRAY,@pos1+1,@pos2-@pos1)

         select @pos3 = Charindex('+',@IN_ARRAY,@pos2+1)
         select @cExerc = Substring(@IN_ARRAY,@pos2+1,@pos3-@pos2)

         select @pos4 = Charindex('#',@IN_ARRAY,@pos3+1)
         select @cMoeda = Substring(@IN_ARRAY,@pos3+1,@pos4-@pos3)      
  
         select @Prox = @pos4 - @pos1
  
      /* -------------------------------------------------------------------
            Data Inicial e Final a serem processadas - Ct400Data()
         -------------------------------------------------------------------*/
      select @dDataIni = Min(CTG_DTINI)
        from CTG### 
       where CTG_FILIAL = @cFil_CTG
         and CTG_CALEND = @cCalend
         and D_E_L_E_T_     = ' '
                      
      select @dDataFin = Max(CTG_DTFIM)
        from CTG### 
       where CTG_FILIAL = @cFil_CTG
         and CTG_CALEND = @cCalend 
         and D_E_L_E_T_     = ' '
      
      /* -------------------------------------------------------------------------- 
        Atualiza flags de saldos encerrados nos arquivos de saldos  - Ct400Saldo()
        --------------------------------------------------------------------------*/
      /* ----------------------------------------------------------------------
               Atualiza flag da tabela CT7 (CT7_STATUS)
         -------------------------------------------------------------------------*/
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CT7### 
       where CT7_FILIAL between @IN_FILIALDE and @IN_FILIALATE
         and CT7_DATA   between @dDataIni   and @dDataFin
         and CT7_MOEDA  = @cMoeda
         and D_E_L_E_T_     = ' '
      
      If @iMinRecno <> 0 begin
         While ( @iMinRecno <= @iMaxRecno ) begin
            update CT7###
               set CT7_STATUS =  '2'
             where R_E_C_N_O_ between @iMinRecno   and @iMinRecno+ 4096
               and CT7_FILIAL between @IN_FILIALDE and @IN_FILIALATE
               and CT7_DATA   between @dDataIni   and @dDataFin
               and CT7_MOEDA  = @cMoeda
               and D_E_L_E_T_     = ' '
            
            select @iMinRecno = @iMinRecno + 4096
         End
      End
      
      /* -------------------------------------------------------------------------
               Atualiza flag da tabela CT3 (CT3_STATUS)
         -------------------------------------------------------------------------*/
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CT3### 
       where CT3_FILIAL between @IN_FILIALDE and @IN_FILIALATE
         and CT3_DATA   between @dDataIni   and @dDataFin
         and CT3_MOEDA  = @cMoeda
         and D_E_L_E_T_     = ' '
      
      If @iMinRecno <> 0 begin
         While ( @iMinRecno <= @iMaxRecno ) 
         begin
            update CT3###
               set CT3_STATUS =  '2'
             where R_E_C_N_O_ between @iMinRecno   and @iMinRecno+ 4096
               and CT3_FILIAL between @IN_FILIALDE and @IN_FILIALATE
               and CT3_DATA   between @dDataIni   and @dDataFin
               and CT3_MOEDA  = @cMoeda
               and D_E_L_E_T_     = ' '
         
            select @iMinRecno = @iMinRecno + 4096
         End
      End
      
      /* -------------------------------------------------------------------------
               Atualiza flag da tabela CT4 (CT4_STATUS)
         -------------------------------------------------------------------------*/
      
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CT4### 
       where CT4_FILIAL between @IN_FILIALDE and @IN_FILIALATE
         and CT4_DATA   between @dDataIni   and @dDataFin
         and CT4_MOEDA  = @cMoeda
         and D_E_L_E_T_     = ' '
      
      If @iMinRecno <> 0 begin
         While ( @iMinRecno <= @iMaxRecno ) 
         begin
            update CT4###
               set CT4_STATUS =  '2'
             where R_E_C_N_O_ between @iMinRecno   and @iMinRecno+ 4096
               and CT4_FILIAL between @IN_FILIALDE and @IN_FILIALATE
               and CT4_DATA   between @dDataIni   and @dDataFin
               and CT4_MOEDA  = @cMoeda
               and D_E_L_E_T_     = ' '
         
            select @iMinRecno = @iMinRecno + 4096
         End
      End
      /* -------------------------------------------------------------------------
               Atualiza flag da tabela CTI (CTI_STATUS)
         -------------------------------------------------------------------------*/
      
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CTI### 
       where CTI_FILIAL between @IN_FILIALDE and @IN_FILIALATE
         and CTI_DATA   between @dDataIni   and @dDataFin
         and CTI_MOEDA  = @cMoeda
         and D_E_L_E_T_     = ' '
      
      If @iMinRecno <> 0 begin
         While ( @iMinRecno <= @iMaxRecno ) begin
            update CTI###
               set CTI_STATUS =  '2'
             where R_E_C_N_O_ between @iMinRecno   and @iMinRecno+ 4096
               and CTI_FILIAL between @IN_FILIALDE and @IN_FILIALATE
               and CTI_DATA   between @dDataIni   and @dDataFin
               and CTI_MOEDA  = @cMoeda
               and D_E_L_E_T_     = ' '
            
            select @iMinRecno = @iMinRecno + 4096
         End
      End
      
      /* -------------------------------------------------------------------------
               Atualiza flag da tabela CT6 (CT6_STATUS)
         -------------------------------------------------------------------------*/
      
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CT6### 
       where CT6_FILIAL between @IN_FILIALDE and @IN_FILIALATE
         and CT6_DATA   between @dDataIni   and @dDataFin
         and CT6_MOEDA  = @cMoeda
         and D_E_L_E_T_     = ' '
      
      If @iMinRecno <> 0 begin
         While ( @iMinRecno <= @iMaxRecno ) begin
            update CT6###
               set CT6_STATUS =  '2'
             where R_E_C_N_O_ between @iMinRecno   and @iMinRecno+ 4096
               and CT6_FILIAL between @IN_FILIALDE and @IN_FILIALATE
               and CT6_DATA   between @dDataIni   and @dDataFin
               and CT6_MOEDA  = @cMoeda
               and D_E_L_E_T_     = ' '
         
            select @iMinRecno = @iMinRecno + 4096
         End
      End
      
      /* -------------------------------------------------------------------------
               Atualiza flag da tabela CTC (CTC_STATUS)
         -------------------------------------------------------------------------*/
      
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CTC### 
       where CTC_FILIAL between @IN_FILIALDE and @IN_FILIALATE
         and CTC_DATA   between @dDataIni   and @dDataFin
         and CTC_MOEDA  = @cMoeda
         and D_E_L_E_T_     = ' '
      
      If @iMinRecno <> 0 begin
         While ( @iMinRecno <= @iMaxRecno ) begin
            update CTC###
               set CTC_STATUS =  '2'
             where R_E_C_N_O_ between @iMinRecno   and @iMinRecno+ 4096
               and CTC_FILIAL between @IN_FILIALDE and @IN_FILIALATE
               and CTC_DATA   between @dDataIni   and @dDataFin
               and CTC_MOEDA  = @cMoeda
               and D_E_L_E_T_     = ' '
         
            select @iMinRecno = @iMinRecno + 4096
         End
      End
      
      /* -------------------------------------------------------------------------
               Atualiza flag da tabela CTU (CTU_STATUS)
         -------------------------------------------------------------------------*/
      
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CTU### 
       where CTU_FILIAL between @IN_FILIALDE and @IN_FILIALATE
         and CTU_DATA   between @dDataIni   and @dDataFin
         and CTU_MOEDA  = @cMoeda
         and D_E_L_E_T_     = ' '
      
      If @iMinRecno <> 0 begin
         While ( @iMinRecno <= @iMaxRecno ) begin
            update CTU###
               set CTU_STATUS =  '2'
             where R_E_C_N_O_ between @iMinRecno   and @iMinRecno+ 4096
               and CTU_FILIAL between @IN_FILIALDE and @IN_FILIALATE
               and CTU_DATA   between @dDataIni   and @dDataFin
               and CTU_MOEDA  = @cMoeda
               and D_E_L_E_T_     = ' '
         
            select @iMinRecno = @iMinRecno + 4096
         End
      End
      
      /* -------------------------------------------------------------------------
               Atualiza flag da tabela CTV (CTV_STATUS)
         -------------------------------------------------------------------------*/
      
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CTV### 
       where CTV_FILIAL between @IN_FILIALDE and @IN_FILIALATE
         and CTV_DATA   between @dDataIni   and @dDataFin
         and CTV_MOEDA  = @cMoeda
         and D_E_L_E_T_     = ' '
      
      If @iMinRecno <> 0 begin
         While ( @iMinRecno <= @iMaxRecno ) begin
            update CTV###
               set CTV_STATUS =  '2'
             where R_E_C_N_O_ between @iMinRecno   and @iMinRecno+ 4096
               and CTV_FILIAL between @IN_FILIALDE and @IN_FILIALATE
               and CTV_DATA   between @dDataIni   and @dDataFin
               and CTV_MOEDA  = @cMoeda
               and D_E_L_E_T_     = ' '
            
            select @iMinRecno = @iMinRecno + 4096
         End
      End
      
      /* -------------------------------------------------------------------------
               Atualiza flag da tabela CTW (CTW_STATUS)
         -------------------------------------------------------------------------*/
      
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CTW### 
       where CTW_FILIAL between @IN_FILIALDE and @IN_FILIALATE
         and CTW_DATA   between @dDataIni   and @dDataFin
         and CTW_MOEDA  = @cMoeda
         and D_E_L_E_T_     = ' '
      
      If @iMinRecno <> 0 begin
         While ( @iMinRecno <= @iMaxRecno ) begin
            update CTW###
               set CTW_STATUS =  '2'
             where R_E_C_N_O_ between @iMinRecno   and @iMinRecno+ 4096
               and CTW_FILIAL between @IN_FILIALDE and @IN_FILIALATE
               and CTW_DATA   between @dDataIni   and @dDataFin
               and CTW_MOEDA  = @cMoeda
               and D_E_L_E_T_     = ' '
          
            select @iMinRecno = @iMinRecno + 4096
         End
      End
      
      /* -------------------------------------------------------------------------
               Atualiza flag da tabela CTX (CTX_STATUS)
         -------------------------------------------------------------------------*/
      
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CTX### 
       where CTX_FILIAL between @IN_FILIALDE and @IN_FILIALATE
         and CTX_DATA   between @dDataIni   and @dDataFin
         and CTX_MOEDA  = @cMoeda
         and D_E_L_E_T_     = ' '
      
      If @iMinRecno <> 0 begin
         While ( @iMinRecno <= @iMaxRecno ) begin
            update CTX###
               set CTX_STATUS =  '2'
             where R_E_C_N_O_ between @iMinRecno   and @iMinRecno+ 4096
               and CTX_FILIAL between @IN_FILIALDE and @IN_FILIALATE
               and CTX_DATA   between @dDataIni   and @dDataFin
               and CTX_MOEDA  = @cMoeda
               and D_E_L_E_T_     = ' '
         
            select @iMinRecno = @iMinRecno + 4096
         End
      End
      
      /* -------------------------------------------------------------------------
               Atualiza flag do calendario contabil CTG - Ct400CTG()
         -------------------------------------------------------------------------*/
      
      update CTG###
         set CTG_STATUS =  '2' 
       where CTG_FILIAL between @IN_FILIALDE and @IN_FILIALATE
         and CTG_CALEND = @cCalend
         and CTG_EXERC  = @cExerc
         and D_E_L_E_T_     = ' '
      
      select @x = @x + 1
      
   End
   
   select @OUT_RESULTADO = '1'
   
End


