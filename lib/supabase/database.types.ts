export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[];

export type Database = {
  public: {
    Tables: {
      clients: {
        Row: {
          id: string;
          name: string;
          link: string | null;
          sales_executive_id: string | null;
          account_manager_id: string;
          _created_at: string;
          _created_by: string;
          _updated_at: string | null;
          _updated_by: string | null;
          _deleted: boolean;
        };
        Insert: {
          id?: string;
          name: string;
          link?: string | null;
          sales_executive_id?: string | null;
          account_manager_id: string;
          _created_at?: string;
          _created_by: string;
          _updated_at?: string | null;
          _updated_by?: string | null;
          _deleted?: boolean;
        };
        Update: {
          id?: string;
          name?: string;
          link?: string | null;
          sales_executive_id?: string | null;
          account_manager_id?: string;
          _created_at?: string;
          _created_by?: string;
          _updated_at?: string | null;
          _updated_by?: string | null;
          _deleted?: boolean;
        };
        Relationships: [
          {
            foreignKeyName: "clients_account_manager_id_fkey";
            columns: ["account_manager_id"];
            referencedRelation: "users";
            referencedColumns: ["id"];
          },
          {
            foreignKeyName: "clients_sales_executive_id_fkey";
            columns: ["sales_executive_id"];
            referencedRelation: "users";
            referencedColumns: ["id"];
          },
        ];
      };
      client_representatives: {
        Row: {
          client_id: string;
          user_id: string;
        };
        Insert: {
          client_id: string;
          user_id: string;
        };
        Update: {
          client_id?: string;
          user_id?: string;
        };
        Relationships: [
          {
            foreignKeyName: "client_representatives_client_id_fkey";
            columns: ["client_id"];
            referencedRelation: "clients";
            referencedColumns: ["id"];
          },
          {
            foreignKeyName: "client_representatives_user_id_fkey";
            columns: ["user_id"];
            referencedRelation: "users";
            referencedColumns: ["id"];
          },
        ];
      };
      employees: {
        Row: {
          id: string;
          first_name: string;
          last_name: string;
          email: string;
          job_title: string | null;
          department: string | null;
          is_active: boolean;
          work_start_date: string | null;
          work_end_date: string | null;
          manager_id: string | null;
          employment_type: "employee" | "contractor" | "trainee";
          job_function_track: string | null;
          job_function_name: string | null;
          job_function_level: string | null;
          _created_at: string;
          _created_by: string;
          _updated_at: string | null;
          _updated_by: string | null;
          _deleted: boolean;
        };
        Insert: {
          id?: string;
          first_name: string;
          last_name: string;
          email: string;
          job_title?: string | null;
          department?: string | null;
          is_active?: boolean;
          work_start_date?: string | null;
          work_end_date?: string | null;
          manager_id?: string | null;
          employment_type?: "employee" | "contractor" | "trainee";
          job_function_track?: string | null;
          job_function_name?: string | null;
          job_function_level?: string | null;
          _created_at?: string;
          _created_by: string;
          _updated_at?: string | null;
          _updated_by?: string | null;
          _deleted?: boolean;
        };
        Update: {
          id?: string;
          first_name?: string;
          last_name?: string;
          email?: string;
          job_title?: string | null;
          department?: string | null;
          is_active?: boolean;
          work_start_date?: string | null;
          work_end_date?: string | null;
          manager_id?: string | null;
          employment_type?: "employee" | "contractor" | "trainee";
          job_function_track?: string | null;
          job_function_name?: string | null;
          job_function_level?: string | null;
          _created_at?: string;
          _created_by?: string;
          _updated_at?: string | null;
          _updated_by?: string | null;
          _deleted?: boolean;
        };
        Relationships: [];
      };
      users: {
        Row: {
          id: string;
          name: string;
          email: string;
          is_active: boolean;
          employee_id: string | null;
          _created_at: string;
          _created_by: string;
          _updated_at: string | null;
          _updated_by: string | null;
          _deleted: boolean;
        };
        Insert: {
          id: string;
          name: string;
          email: string;
          is_active?: boolean;
          employee_id?: string | null;
          _created_at?: string;
          _created_by: string;
          _updated_at?: string | null;
          _updated_by?: string | null;
          _deleted?: boolean;
        };
        Update: {
          id?: string;
          name?: string;
          email?: string;
          is_active?: boolean;
          employee_id?: string | null;
          _created_at?: string;
          _created_by?: string;
          _updated_at?: string | null;
          _updated_by?: string | null;
          _deleted?: boolean;
        };
        Relationships: [];
      };
    };
    Views: Record<string, never>;
    Functions: Record<string, never>;
    Enums: {
      employment_type: "employee" | "contractor" | "trainee";
    };
    CompositeTypes: Record<string, never>;
  };
};
