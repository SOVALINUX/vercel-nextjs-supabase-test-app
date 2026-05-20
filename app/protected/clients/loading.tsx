export default function ClientsLoading() {
  return (
    <div className="flex flex-col gap-6">
      <div className="flex items-center justify-between">
        <div className="h-8 w-32 rounded bg-muted animate-pulse" />
        <div className="h-9 w-28 rounded bg-muted animate-pulse" />
      </div>
      <div className="rounded-md border">
        <div className="p-4 space-y-3">
          {Array.from({ length: 5 }).map((_, i) => (
            <div key={i} className="h-6 rounded bg-muted animate-pulse" />
          ))}
        </div>
      </div>
    </div>
  );
}
